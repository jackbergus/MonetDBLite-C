
#include "emit.h"
#include "type_conversion.h"
#include "interprocess.h"

#include "convert_loops.h"

#if PY_MAJOR_VERSION >= 3
#define IS_PY3K
#define PyString_FromString PyUnicode_FromString
#define PyString_Check PyUnicode_Check
#define PyString_CheckExact PyUnicode_CheckExact
#define PyString_AsString PyUnicode_AsUTF8
#define PyString_AS_STRING PyUnicode_AsUTF8
#define PyInt_FromLong PyLong_FromLong
#define PyInt_Check PyLong_Check
#define PythonUnicodeType char
#else
#define PythonUnicodeType Py_UNICODE
#endif

#define scalar_convert(tpe) {\
    tpe val = (tpe) tpe##_nil; msg = pyobject_to_##tpe(&dictEntry, 42, &val); \
    BUNappend(self->cols[i].b, &val, 0); \
    if (msg != MAL_SUCCEED) { \
        PyErr_Format(PyExc_TypeError, "Conversion Failed: %s", msg); \
        return NULL; \
    }}

static PyObject *
_emit_emit(Py_EmitObject *self, PyObject *args) {
    size_t i, ai; // iterators
    ssize_t el_count = -1; // the amount of elements this emit call will write to the table
    size_t dict_elements, matched_elements;
    str msg = MAL_SUCCEED; // return message

    if (!PyDict_Check(args)) {
        PyErr_SetString(PyExc_TypeError, "need dict");
        return NULL;
    }

    matched_elements = 0;
    dict_elements = PyDict_Size(args);
    if (dict_elements == 0) {
        PyErr_SetString(PyExc_TypeError, "dict must contain at least one element");
        return NULL;
    }
    for (i = 0; i < self->ncols; i++) {
        PyObject *dictEntry = PyDict_GetItemString(args, self->cols[i].name);
        if (dictEntry) {
            ssize_t this_size = 1;
            matched_elements++;
            this_size = PyType_Size(dictEntry);
            if (this_size < 0) {
                PyErr_Format(PyExc_TypeError, "Unsupported Python Object %s", PyString_AsString(PyObject_Str(PyObject_Type(dictEntry))));
                return NULL;
            }
            if (el_count < 0) {
                el_count = this_size;
            } else if (el_count != this_size) {
                PyErr_Format(PyExc_TypeError, "Element %s has size %zu, but expected an element with size %zu", self->cols[i].name, this_size, el_count);
                return NULL;
            }
        }
    }
    if (el_count == 0) {
        PyErr_SetString(PyExc_TypeError, "Empty input values supplied");
        return NULL;
    }
    if (matched_elements != dict_elements) {
        // not all elements in the dictionary were matched, look for the element that was not matched
        PyObject *keys = PyDict_Keys(args);
        for(i = 0; i < (size_t) PyList_Size(keys); i++) {
            PyObject *key = PyList_GetItem(keys, i);
            char *val;
            if (!PyString_CheckExact(key)) {
                // one of the keys in the dictionary was not a string
                PyErr_Format(PyExc_TypeError, "Expected a string as dict key, but found %s", PyString_AsString(PyObject_Str(PyObject_Type(key))));
                goto loop_end;
            }
            val = PyString_AsString(key);
            bool found = false;
            for(ai = 0; ai < self->ncols; ai++) {
                if (strcmp(val, self->cols[ai].name) == 0) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                // the current element was present in the dictionary, but it has no matching column
                PyErr_Format(PyExc_TypeError, "Unmatched element \"%s\" in dict", val);
                goto loop_end;
            }
        }
loop_end:
        Py_DECREF(keys);
        goto wrapup;
    }

    for (i = 0; i < self->ncols; i++) {
        PyObject *dictEntry = PyDict_GetItemString(args, self->cols[i].name);
        if (dictEntry && dictEntry != Py_None) {
            if (PyType_IsPyScalar(dictEntry)) {
                switch (self->cols[i].b->T->type)
                    {
                    case TYPE_bit:
                        scalar_convert(bit);
                        break;
                    case TYPE_bte:
                        scalar_convert(bte);
                        break;
                    case TYPE_sht:
                        scalar_convert(sht);
                        break;
                    case TYPE_int:
                        scalar_convert(int);
                        break;
                    case TYPE_oid:
                        scalar_convert(oid);
                        break;
                    case TYPE_lng:
                        scalar_convert(lng);
                        break;
                    case TYPE_flt:
                        scalar_convert(flt);
                        break;
                    case TYPE_dbl:
                        scalar_convert(dbl);
                        break;
                #ifdef HAVE_HGE
                    case TYPE_hge:
                        scalar_convert(hge);
                        break;
                #endif
                    case TYPE_str:
                    {
                        str val = NULL;
                        msg = pyobject_to_str(&dictEntry, 42, &val);
                        BUNappend(self->cols[i].b, val, 0);
                        if (val) {
                            free(val);
                        }
                        if (msg != MAL_SUCCEED) {
                            PyErr_Format(PyExc_TypeError, "Conversion Failed: %s", msg);
                            return NULL;
                        }
                    }
                        break;
                    default:
                        PyErr_Format(PyExc_TypeError, "Unsupported BAT Type %s", BatType_Format(self->cols[i].b->T->type));
                        return NULL;
                }
            } else {
                bool *mask = NULL;
                char *data = NULL;
                PyReturn return_struct;
                PyReturn *ret = &return_struct;
                size_t index_offset = 0;
                size_t iu = 0;
                if (BATextend(self->cols[i].b, self->nvals + el_count) != GDK_SUCCEED) {
                    PyErr_Format(PyExc_TypeError, "Failed to allocate memory to extend BAT.");
                    return NULL;
                }
                msg = PyObject_GetReturnValues(dictEntry, ret);
                if (ret->mask_data != NULL) {
                    mask = (bool*) ret->mask_data;
                }
                if (ret->array_data == NULL) {
                    msg = createException(MAL, "pyapi.eval", "No return value stored in the structure.\n");
                    goto wrapup;
                }
                data = (char*) ret->array_data;
                assert((size_t) el_count == (size_t) ret->count);
                switch (self->cols[i].b->T->type) {
                    case TYPE_bit:
                        NP_INSERT_BAT(self->cols[i].b, bit, self->nvals);
                        break;
                    case TYPE_bte:
                        NP_INSERT_BAT(self->cols[i].b, bte, self->nvals);
                        break;
                    case TYPE_sht:
                        NP_INSERT_BAT(self->cols[i].b, sht, self->nvals);
                        break;
                    case TYPE_int:
                        NP_INSERT_BAT(self->cols[i].b, int, self->nvals);
                        break;
                    case TYPE_oid:
                        NP_INSERT_BAT(self->cols[i].b, oid, self->nvals);
                        break;
                    case TYPE_lng:
                        NP_INSERT_BAT(self->cols[i].b, lng, self->nvals);
                        break;
                    case TYPE_flt:
                        NP_INSERT_BAT(self->cols[i].b, flt, self->nvals);
                        break;
                    case TYPE_dbl:
                        NP_INSERT_BAT(self->cols[i].b, dbl, self->nvals);
                        break;
                #ifdef HAVE_HGE
                    case TYPE_hge:
                        NP_INSERT_BAT(self->cols[i].b, hge, self->nvals);
                        break;
                #endif
                    case TYPE_str:
                    default:
                        PyErr_Format(PyExc_TypeError, "Unsupported BAT Type %s", BatType_Format(self->cols[i].b->T->type));
                        return NULL;
                }
                BATsetcount(self->cols[i].b, self->nvals + el_count);
                self->cols[i].b->T->nonil = 1 - self->cols[i].b->T->nil;
            }
        } else {
            for (ai = 0; ai < (size_t) el_count; ai++) {
                BUNappend(self->cols[i].b, ATOMnil(self->cols[i].b->T->type), 0);
            }
            self->cols[i].b->T->nil = 1;
            self->cols[i].b->T->nonil = 0;
        }
    }
    self->nvals += el_count;
    Py_RETURN_NONE;
wrapup:
    if (msg != MAL_SUCCEED) {
        PyErr_Format(PyExc_TypeError, "Failed conversion: %s", msg);
    } else {
        Py_RETURN_NONE;
    }
    return NULL;
}


static PyMethodDef _emitObject_methods[] = {
    {"emit", (PyCFunction)_emit_emit, METH_O,"emit(dictionary) -> returns parsed values for table insertion"},
    {NULL,NULL,0,NULL}  /* Sentinel */
};

PyTypeObject Py_EmitType = {
    PyObject_HEAD_INIT(NULL)
    0,
    "monetdb._emit",
    sizeof(Py_EmitObject),
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
    "Value Emitter",                    /* tp_doc */
    0,                                          /* tp_traverse */
    0,                                          /* tp_clear */
    0,                                          /* tp_richcompare */
    0,                                          /* tp_weaklistoffset */
    0,                                          /* tp_iter */
    0,                                          /* tp_iternext */
    _emitObject_methods,                  /* tp_methods */
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



PyObject *Py_Emit_Create(EmitCol *cols, size_t ncols)
{
    register Py_EmitObject *op;

    op = (Py_EmitObject *)PyObject_MALLOC(sizeof(Py_EmitObject));
    if (op == NULL)
        return PyErr_NoMemory();
    PyObject_Init((PyObject*)op, &Py_EmitType);
    op->cols = cols;
    op->ncols = ncols;
    op->nvals = 0;
    return (PyObject*) op;
}

str _emit_init(void)
{
    _import_array();
    if (PyType_Ready(&Py_EmitType) < 0)
        return createException(MAL, "pyapi.eval", "Failed to initialize emit type.");
    return MAL_SUCCEED;
}
