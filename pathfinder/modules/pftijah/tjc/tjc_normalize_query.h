/* -*- c-basic-offset:4; c-indentation-style:"k&r"; indent-tabs-mode:nil -*- */

/**
* Copyright Notice:
* -----------------
*
* The contents of this file are subject to the PfTijah Public License
* Version 1.1 (the "License"); you may not use this file except in
* compliance with the License. You may obtain a copy of the License at
* http://dbappl.cs.utwente.nl/Legal/PfTijah-1.1.html
*
* Software distributed under the License is distributed on an "AS IS"
* basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
* License for the specific language governing rights and limitations
* under the License.
*
* The Original Code is the PfTijah system.
*
* The Initial Developer of the Original Code is the "University of Twente".
* Portions created by the "University of Twente" are
* Copyright (C) 2006-2011 "University of Twente".
*
* Portions created by the "CWI" are
* Copyright (C) 2008-2011 "CWI".
*
* All Rights Reserved.
* 
* Author(s): Henning Rode 
*            Jan Flokstra
*/

#ifndef NORMALIZE_QUERY_H
#define NORMALIZE_QUERY_H

#include "tjc_abssyn.h"
#include "tjc_conf.h"

void 
normalize_query(tjc_config* tjc_c, TJptree_t *ptree);


#endif  /* NORMALIZE_QUERY_H */

/* vim:set shiftwidth=4 expandtab: */
