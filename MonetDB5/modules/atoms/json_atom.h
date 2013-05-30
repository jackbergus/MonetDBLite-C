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
 * Copyright August 2008-2013 MonetDB B.V.
 * All Rights Reserved.
 */

#ifndef JSON_H
#define JSON_H

#include <gdk.h>
#include "mal.h"
#include "mal_client.h"
#include "mal_instruction.h"
#include "mal_exception.h"

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

json_export str JSONfilterObject(json *ret, json *j, str *pat);
json_export str JSONfilterArray(json *ret, json *j, int *index);

json_export str JSONisvalid(int *ret, json *j);
json_export str JSONisobject(int *ret, json *j);
json_export str JSONisarray(int *ret, json *j);

json_export str JSONlength(int *ret, json *j);
json_export str JSONpairs(int *key, int *val, json *j);
json_export str JSONnames(int *ret, json *j);
json_export str JSONvalues(int *ret, json *j);
json_export str JSONprelude(int *ret);
#endif /* JSON_H */
