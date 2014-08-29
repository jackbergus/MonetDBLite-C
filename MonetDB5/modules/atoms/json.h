/*
 * The contents of this file are subject to the MonetDB Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://www.monetdb.org/Legal/MonetDBLicense
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * The Original Code is the MonetDB Database System.
 *
 * The Initial Developer of the Original Code is CWI.
 * Portions created by CWI are Copyright (C) 1997-July 2008 CWI.
 * Copyright August 2008-2014 MonetDB B.V.
 * All Rights Reserved.
 */

#ifndef JSON_H
#define JSON_H

#include <gdk.h>
#include "mal.h"
#include "mal_client.h"
#include "mal_instruction.h"
#include "mal_exception.h"

#define JSON_OBJECT 1
#define JSON_ARRAY 2
#define JSON_ELEMENT 3
#define JSON_VALUE 4
#define JSON_STRING 5
#define JSON_NUMBER 6
#define JSON_BOOL 7
#define JSON_NULL 8

/* The JSON index structure is meant for short lived versions */
typedef struct JSONterm {
    short kind;
    char *name; /* exclude the quotes */
    size_t namelen;
    char *value; /* start of string rep */
    size_t valuelen;
    int child, next, tail; /* next offsets allow you to walk array/object chains and append quickly */
    /* An array or object item has a number of components */
} JSONterm; 

typedef struct JSON{
    JSONterm *elm;
    str error;
    int size;
    int free;
} JSON;

typedef str json;

#ifdef WIN32
#ifndef LIBATOMS
#define json_export extern __declspec(dllimport)
#else
#define json_export extern __declspec(dllexport)
#endif
#else
#define json_export extern
#endif

json_export int TYPE_json;

json_export int JSONfromString(str src, int *len, json *x);
json_export int JSONtoString(str *s, int *len, json src);


json_export str JSONstr2json(json *ret, str *j);
json_export str JSONjson2str(str *ret, json *j);
json_export str JSONjson2text(str *ret, json *arg);
json_export str JSONjson2textSeparator(str *ret, json *arg, str *sep);
json_export str JSONjson2number(dbl *ret, json *arg);
json_export str JSONjson2integer(lng *ret, json *arg);

json_export str JSONfilter( json *ret, json *js, str *expr);
json_export str JSONfilterArray_bte(json *ret, json *j, bte *index);
json_export str JSONfilterArrayDefault_bte(json *ret, json *j, bte *index, str *other);
json_export str JSONfilterArray_sht(json *ret, json *j, sht *index);
json_export str JSONfilterArrayDefault_sht(json *ret, json *j, sht *index, str *other);
json_export str JSONfilterArray_int(json *ret, json *j, int *index);
json_export str JSONfilterArrayDefault_int(json *ret, json *j, int *index, str *other);
json_export str JSONfilterArray_lng(json *ret, json *j, lng *index);
json_export str JSONfilterArrayDefault_lng(json *ret, json *j, lng *index, str *other);
#ifdef HAVE_HGE
json_export str JSONfilterArray_hge(json *ret, json *j, hge *index);
json_export str JSONfilterArrayDefault_hge(json *ret, json *j, hge *index, str *other);
#endif

json_export str JSONisvalid(bit *ret, json *j);
json_export str JSONisobject(bit *ret, json *j);
json_export str JSONisarray(bit *ret, json *j);

json_export str JSONlength(int *ret, json *j);
json_export str JSONunfold(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci);
json_export str JSONfold(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci);
json_export str JSONkeyTable(int *ret, json *j);
json_export str JSONvalueTable(int *ret, json *j);
json_export str JSONkeyArray(json *ret, json *arg);
json_export str JSONvalueArray(json *ret, json *arg);

json_export str JSONtextString(str *ret, int *bid);
json_export str JSONtextGrouped(int *ret, int *bid, int *gid, int *ext, bit *flg);
json_export str JSONdump(int *ret, json *val);
json_export str JSONprelude(int *ret);

json_export str JSONrenderobject(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci);
json_export str JSONrenderarray(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci);
json_export str JSONgroupStr(str *ret, const bat *bid);
json_export str JSONsubjsoncand(bat *retval, bat *bid, bat *gid, bat *eid, bat *id, bit *skip_nils);
json_export str JSONsubjson(bat *retval, bat *bid, bat *gid, bat *eid, bit *skipnils);
#endif /* JSON_H */
