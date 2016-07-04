
/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0.  If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright 2008-2015 MonetDB B.V.
 */

/*
 * M.Raasveldt & H. Muehleisen
 * The Python interface
 */
#ifndef _PYPI_LIB_
#define _PYPI_LIB_

#include "monetdb_config.h"
#include "mal.h"
#include "mal_stack.h"
#include "mal_linker.h"
#include "gdk_atoms.h"
#include "gdk_utils.h"
#include "gdk_posix.h"
#include "gdk.h"
#include "sql_catalog.h"
#include "sql_scenario.h"
#include "sql_cast.h"
#include "sql_execute.h"
#include "sql_storage.h"

#include "unspecified_evil.h"

// Python library
#undef _GNU_SOURCE
#undef _XOPEN_SOURCE
#undef _POSIX_C_SOURCE
#ifdef _DEBUG
 #undef _DEBUG
 #include <Python.h>
 #define _DEBUG
#else
 #include <Python.h>
#endif


// Numpy Library
#define NPY_NO_DEPRECATED_API NPY_1_7_API_VERSION
#ifdef __INTEL_COMPILER
// Intel compiler complains about trailing comma's in numpy source code,
#pragma warning(disable:271)
#endif
#include <numpy/arrayobject.h>
#include <numpy/npy_common.h>

// For some presumably very good reason the NumPy function import_array() returns NULL in Python3 and nothing (void type) in Python2
#if PY_VERSION_HEX >= 0x03000000
#define NUMPY_IMPORT_ARRAY_RETTYPE void*
#define PYFUNCNAME(name) PYAPI3##name
#else
#define NUMPY_IMPORT_ARRAY_RETTYPE void
#define PYFUNCNAME(name) PYAPI2##name
#endif

#ifndef NDEBUG
// Enable verbose output, note that this #define must be set and mserver must be started with --set <verbose_enableflag>=true
#define _PYAPI_VERBOSE_
// Enable performance warnings, note that this #define must be set and mserver must be started with --set <warning_enableflag>=true
#define _PYAPI_WARNINGS_
// Enable debug mode, does literally nothing right now, but hey we have this nice #define here anyway
#define _PYAPI_DEBUG_
#endif

#ifdef _PYAPI_VERBOSE_
#define VERBOSE_MESSAGE(...) {              \
    if (option_verbose) {                   \
    printf(__VA_ARGS__);                    \
    fflush(stdout); }                       \
}
#else
#define VERBOSE_MESSAGE(...) ((void) 0)
#endif

#ifdef _PYAPI_WARNINGS_
extern bool option_warning;
#define WARNING_MESSAGE(...) {           \
    if (option_warning) {                \
    fprintf(stderr, __VA_ARGS__);        \
    fflush(stdout);     }                \
}
#else
#define WARNING_MESSAGE(...) ((void) 0)
#endif

#ifdef WIN32
#ifndef LIBPYAPI
#define pyapi_export extern __declspec(dllimport)
#else
#define pyapi_export extern __declspec(dllexport)
#endif
#else
#define pyapi_export extern
#endif

pyapi_export str PYFUNCNAME(PyAPIevalStd)(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci);
pyapi_export str PYFUNCNAME(PyAPIevalAggr)(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci);
pyapi_export str PYFUNCNAME(PyAPIevalStdMap)(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci);
pyapi_export str PYFUNCNAME(PyAPIevalAggrMap)(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci);

pyapi_export str PYFUNCNAME(PyAPIprelude)(void *ret);

#ifdef WIN32
#define CREATE_SQL_FUNCTION_PTR(retval, fcnname)     \
   typedef retval (*fcnname##_ptr_tpe)();            \
   fcnname##_ptr_tpe fcnname##_ptr = NULL;

#define LOAD_SQL_FUNCTION_PTR(fcnname)                                             \
    fcnname##_ptr = (fcnname##_ptr_tpe) getAddress(NULL, "lib_sql.dll", NULL, #fcnname, 0); \
    if (fcnname##_ptr == NULL) {                                                           \
        msg = createException(MAL, "pyapi.eval", "Failed to load function %s", #fcnname);  \
    }
#else
#define CREATE_SQL_FUNCTION_PTR(retval, fcnname)     \
   typedef retval (*fcnname##_ptr_tpe)();            \
   fcnname##_ptr_tpe fcnname##_ptr = (fcnname##_ptr_tpe)fcnname;

#define LOAD_SQL_FUNCTION_PTR(fcnname) (void) fcnname
#endif


#endif /* _PYPI_LIB_ */
