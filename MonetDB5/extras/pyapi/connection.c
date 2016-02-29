
#include "connection.h"
#include "type_conversion.h"
#include "shared_memory.h"

#if PY_MAJOR_VERSION >= 3
#define IS_PY3K
#define PyString_CheckExact PyUnicode_CheckExact
#define PyString_FromString PyUnicode_FromString
#endif

CREATE_SQL_FUNCTION_PTR(void,res_table_destroy,(res_table*));
CREATE_SQL_FUNCTION_PTR(str,SQLstatementIntern_ext,(Client, str *, str, int, bit, res_table **, bit));

static PyObject *
_connection_execute(Py_ConnectionObject *self, PyObject *args)
{
    if (!PyString_CheckExact(args)) {
            PyErr_Format(PyExc_TypeError,
                         "expected a query string, but got an object of type %s", Py_TYPE(args)->tp_name);
            return NULL;
    }
    if (!self->mapped)
    {
        // This is not a mapped process, so we can just directly execute the query here
        PyObject *result;
        res_table* output = NULL;
        char *res = NULL;
        char *query;
#ifndef IS_PY3K
        query = ((PyStringObject*)args)->ob_sval;
#else
        query = PyUnicode_AsUTF8(args);
#endif

        res = _connection_query(self->cntxt, query, &output);
        if (res != MAL_SUCCEED) {
            PyErr_Format(PyExc_Exception, "SQL Query Failed: %s", (res ? res : "<no error>"));
            return NULL;
        }

        result = PyDict_New();
        if (output && output->nr_cols > 0) {
            PyInput input;
            PyObject *numpy_array;
            int i;
            for (i = 0; i < output->nr_cols; i++) {
                res_col col = output->cols[i];
                BAT* b = BATdescriptor(col.b);

                input.bat = b;
                input.count = BATcount(b);
                input.bat_type = getColumnType(b->T->type);
                input.scalar = false;
                input.sql_subtype = &col.type;

                numpy_array = PyMaskedArray_FromBAT(&input, 0, input.count, &res, true);
                if (!numpy_array) {
                    _connection_cleanup_result(output);
                    PyErr_Format(PyExc_Exception, "SQL Query Failed: %s", (res ? res : "<no error>"));
                    return NULL;
                }
                PyDict_SetItem(result, PyString_FromString(output->cols[i].name), numpy_array);
                Py_DECREF(numpy_array);
                BBPunfix(b->batCacheid);
            }
            _connection_cleanup_result(output);
            return result;
        } else {
            Py_RETURN_NONE;
        }
    }
    else 
#ifdef HAVE_FORK
    {
        char *query;
#ifndef IS_PY3K
        query = ((PyStringObject*)args)->ob_sval;
#else
        query = PyUnicode_AsUTF8(args);
#endif
        // This is a mapped process, we do not want forked processes to touch the database
        // Only the main process may touch the database, so we ship the query back to the main process
        // copy the query into shared memory and tell the main process there is a query to handle
        strncpy(self->query_ptr->query, query, 8192);
        self->query_ptr->pending_query = true;
        //free the main process so it can work on the query
        change_semaphore_value(self->query_sem, 0, 1);
        //now wait for the main process to finish
        change_semaphore_value(self->query_sem, 1, -1);
        if (self->query_ptr->pending_query) {
            //the query failed in the main process
            //           life is hopeless
            //there is no reason to continue to live
            //                so we commit sudoku
            exit(0);
        }

        if (self->query_ptr->memsize > 0) // check if there are return values
        {
            char *msg; 
            char *ptr;
            PyObject *numpy_array;
            size_t position = 0; 
            PyObject *result;
            int i;
            
            // get a pointer to the shared memory holding the return values
            msg = init_mmap_memory(self->query_ptr->mmapid, 0, self->query_ptr->memsize, NULL, NULL, &ptr);
            if (msg != MAL_SUCCEED) {
                PyErr_Format(PyExc_Exception, "%s", msg);
                return NULL;
            }

            result = PyDict_New();
            for(i = 0; i < self->query_ptr->nr_cols; i++)
            {
                BAT *b;
                char *colname;
                PyInput input;

                //load the data for this column from shared memory
                //[COLNAME]
                colname = ptr + position; 
                position += strlen(colname) + 1;
                //[BAT]
                b = (BAT*) (ptr + position); 
                position += sizeof(BAT);
                //[COLrec]
                b->T = (COLrec*) (ptr + position); 
                position += sizeof(COLrec);
                //[BATrec]
                b->S = (BATrec*) (ptr + position); 
                position += sizeof(BATrec);
                //[DATA]
                b->T->heap.base = (void*)(ptr + position); 
                position += b->T->width * BATcount(b);
                if (b->T->vheap != NULL) {
                    //[VHEAP]
                    b->T->vheap = (Heap*) (ptr + position); 
                    position += sizeof(Heap);
                    //[VHEAPDATA]
                    b->T->vheap->base = (void*) (ptr + position); 
                    position += b->T->vheap->size;
                }
                //initialize the PyInput structure
                input.bat = b;
                input.count = BATcount(b);
                input.bat_type = b->T->type;
                input.scalar = false;
                input.sql_subtype = NULL;

                numpy_array = PyMaskedArray_FromBAT(&input, 0, input.count, &msg, true);
                if (!numpy_array) {
                    PyErr_Format(PyExc_Exception, "SQL Query Failed: %s", (msg ? msg : "<no error>"));
                    release_mmap_memory(ptr, self->query_ptr->memsize, self->query_ptr->mmapid);
                    return NULL;
                }
                PyDict_SetItem(result, PyString_FromString(colname), numpy_array);
                Py_DECREF(numpy_array);
            }
            release_mmap_memory(ptr, self->query_ptr->memsize, self->query_ptr->mmapid);
            return result;
        }

        Py_RETURN_NONE;
    }
#else
    {
        PyErr_Format(PyExc_Exception, "Mapped is not supported on Windows.");
        return NULL;
    }
#endif
}

static PyMethodDef _connectionObject_methods[] = {
    {"execute", (PyCFunction)_connection_execute, METH_O,"execute(query) -> executes a SQL query on the database in the current client context"},
    {NULL,NULL,0,NULL}  /* Sentinel */
};

PyTypeObject Py_ConnectionType = {
    PyObject_HEAD_INIT(NULL)
    0,
    "monetdb._connection",
    sizeof(Py_ConnectionObject),
    0,
    0,                                          /* tp_dealloc */
    0,                                          /* tp_print */
    0,                                          /* tp_getattr */
    0,                                          /* tp_setattr */
    0,                                          /* tp_compare */
    0,                                          /* tp_repr */
    0,                                          /* tp_as_number */
    0,                                          /* tp_as_sequence */
    0,                                          /* tp_as_mapping */
    (hashfunc)PyObject_HashNotImplemented,      /* tp_hash */
    0,                                          /* tp_call */
    0,                                          /* tp_str */
    0,                                          /* tp_getattro */
    0,                                          /* tp_setattro */
    0,                                          /* tp_as_buffer */
    Py_TPFLAGS_DEFAULT,                         /* tp_flags */
    "Connection to MonetDB",                    /* tp_doc */
    0,                                          /* tp_traverse */
    0,                                          /* tp_clear */
    0,                                          /* tp_richcompare */
    0,                                          /* tp_weaklistoffset */
    0,                                          /* tp_iter */
    0,                                          /* tp_iternext */
    _connectionObject_methods,                  /* tp_methods */
    0,                                          /* tp_members */
    0,                                          /* tp_getset */
    0,                                          /* tp_base */
    0,                                          /* tp_dict */
    0,                                          /* tp_descr_get */
    0,                                          /* tp_descr_set */
    0,                                          /* tp_dictoffset */
    0,                                          /* tp_init */
    PyType_GenericAlloc,                        /* tp_alloc */
    PyType_GenericNew,                          /* tp_new */
    PyObject_Del,                               /* tp_free */
    0,
    0,
    0,
    0,
    0,
    0, 
    0,
    0
#ifdef IS_PY3K
    ,0
#endif
};

void _connection_cleanup_result(void* output) 
{
    (*res_table_destroy_ptr)((res_table*) output);
}

char* _connection_query(Client cntxt, char* query, res_table** result) {
    str res = MAL_SUCCEED;
    Client c = cntxt;
    res = (*SQLstatementIntern_ext_ptr)(c, &query, "name", 1, 0, result, 1);
    return res;
}


PyObject *Py_Connection_Create(Client cntxt, bit mapped, QueryStruct *query_ptr, int query_sem)
{
    register Py_ConnectionObject *op;

    op = (Py_ConnectionObject *)PyObject_MALLOC(sizeof(Py_ConnectionObject));
    if (op == NULL)
        return PyErr_NoMemory();
    PyObject_Init((PyObject*)op, &Py_ConnectionType);

    op->cntxt = cntxt;
    op->mapped = mapped;
    op->query_ptr = query_ptr;
    op->query_sem = query_sem;

    return (PyObject*) op;
}

void _connection_init(void)
{
    import_array();

    LOAD_SQL_FUNCTION_PTR(res_table_destroy);
    LOAD_SQL_FUNCTION_PTR(SQLstatementIntern_ext);

    if (PyType_Ready(&Py_ConnectionType) < 0)
        return;
}
