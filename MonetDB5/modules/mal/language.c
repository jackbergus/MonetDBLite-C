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

/*
 *  Martin Kersten
 * Language Extensions
 * Iterators over scalar ranges are often needed, also at the MAL level.
 * The barrier and control primitives are sufficient to mimic them directly.
 *
 * The modules located in the kernel directory should not
 * rely on the MAL datastructures. That's why we have to deal with
 * some bat operations here and delegate the signature to the
 * proper module upon loading.
 *
 * Running a script is typically used to initialize a context.
 * Therefore we need access to the runtime context.
 * For the call variants we have
 * to determine an easy way to exchange the parameter/return values.
 */

#include "monetdb_config.h"
#include "language.h"

str
CMDraise(str *ret, str *msg)
{
	*ret = GDKstrdup(*msg);
	return GDKstrdup(*msg);
}

str
MALassertBit(void *ret, bit *val, str *msg){
	(void) ret;
	if( *val == 0 || *val == bit_nil)
		throw(MAL, "mal.assert", "%s", *msg);
	return MAL_SUCCEED;
}
str
MALassertInt(void *ret, int *val, str *msg){
	(void) ret;
	if( *val == 0 || *val == int_nil)
		throw(MAL, "mal.assert", "%s", *msg);
	return MAL_SUCCEED;
}
str
MALassertLng(void *ret, lng *val, str *msg){
	(void) ret;
	if( *val == 0 || *val == lng_nil)
		throw(MAL, "mal.assert", "%s", *msg);
	return MAL_SUCCEED;
}
str
MALassertSht(void *ret, sht *val, str *msg){
	(void) ret;
	if( *val == 0 || *val == sht_nil)
		throw(MAL, "mal.assert", "%s", *msg);
	return MAL_SUCCEED;
}
str
MALassertOid(void *ret, oid *val, str *msg){
	(void) ret;
	if( *val == oid_nil)
		throw(MAL, "mal.assert", "%s", *msg);
	return MAL_SUCCEED;
}
str
MALassertStr(void *ret, str *val, str *msg){
	(void) ret;
	if( *val == str_nil)
		throw(MAL, "mal.assert", "%s", *msg);
	return MAL_SUCCEED;
}

str
MALassertTriple(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr p){
	(void) cntxt;
	(void) mb;
	(void) stk;
	(void) p;
	throw(MAL, "mal.assert", PROGRAM_NYI);
}

/*
 * Printing
 * The print commands are implemented as single instruction rules,
 * because they need access to the calling context.
 * At a later stage we can look into the issues related to
 * parsing the format string as part of the initialization phase.
 * The old method in V4 essentially causes a lot of overhead
 * because you have to prepare for the worst (e.g. mismatch format
 * identifier and argument value)
 *
 * Input redirectionrs
 */
str
CMDcallString(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{
	str *s;

	(void) mb;		/* fool compiler */
	s = getArgReference_str(stk, pci, 1);
	if (strlen(*s) == 0)
		return MAL_SUCCEED;
	callString(cntxt, *s, FALSE);
	return MAL_SUCCEED;
}

str
CMDcallFunction(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{
	str mod = *getArgReference_str(stk,pci,1);
	str fcn = *getArgReference_str(stk,pci,2);
	char buf[BUFSIZ];

	(void) mb;		/* fool compiler */
	if (strlen(mod) == 0 || strlen(fcn) ==0)
		return MAL_SUCCEED;
	// lazy implementation of the call
	snprintf(buf,BUFSIZ,"%s.%s();",mod,fcn);
	callString(cntxt, buf, FALSE);
	return MAL_SUCCEED;
}

str
MALstartDataflow( Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{
	bit *ret = getArgReference_bit(stk,pci,0);
	int pc = getPC(mb,pci);

	if ( pc <0 || pc > pci->jump)
		throw(MAL,"language.dataflow","Illegal statement range");
	*ret = 0;	/* continue at end of block */
	return runMALdataflow(cntxt, mb, pc, pci->jump, stk);
}

/*
 * Garbage collection over variables can be postponed by grouping
 * all dependent ones in a single sink() instruction.
 */
str
MALgarbagesink( Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{
	(void) cntxt;
	(void) mb;
	(void) stk;
	(void) pci;
	return MAL_SUCCEED;
}

str
MALpass( Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{
	(void) cntxt;
	(void) mb;
	(void) stk;
	(void) pci;
	return MAL_SUCCEED;
}

str 
CMDregisterFunction(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{
	Symbol sym= NULL;
	str *mod = getArgReference_str(stk,pci,1);
	str *fcn = getArgReference_str(stk,pci,2);
	str *code = getArgReference_str(stk,pci,3);
	str *help = getArgReference_str(stk,pci,4);
	InstrPtr sig;
	str msg;

	msg= compileString(&sym, cntxt,*code);
	if( sym) {
		mnstr_printf(cntxt->fdout,"#register FUNCTION %s.%s\n",
			getModuleId(sym->def->stmt[0]), getFunctionId(sym->def->stmt[0]));
		mb= sym->def;
		if( help)
			mb->help= GDKstrdup(*help);
		sig= getSignature(sym);
		sym->name= putName(*fcn, strlen(*fcn));
		setModuleId(sig, putName(*mod, strlen(*mod)));
		setFunctionId(sig, sym->name);
		insertSymbol(findModule(cntxt->nspace, getModuleId(sig)), sym);
	}
	return msg;
}
str
CMDevalFile(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{
	str s = *getArgReference_str(stk,pci,1);
	char *msg = NULL;
	(void) mb;

	if (s == 0) 
		throw(MAL, "mal.evalFile", RUNTIME_FILE_NOT_FOUND "missing file name");

	if (*s != '/') {
		char *buf = GDKmalloc(strlen(monet_cwd) + strlen(s) + 2);
		if ( buf == NULL)
			throw(MAL,"language.eval", MAL_MALLOC_FAIL);

		strcpy(buf, monet_cwd);
		strcat(buf, "/");
		strcat(buf, s);
		msg = evalFile(cntxt, buf, 0);
		GDKfree(buf);
	} else 
		msg = evalFile(cntxt, s, 0);
	return msg;
}
/*
 * Calling a BAT is simply translated into a concatenation of
 * all the unquoted strings and then passing it to the callEval.
 */
str
CMDcallBAT(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{
	(void) cntxt;
	(void) mb;
	(void) stk;
	(void) pci;		/* fool compiler */
	throw(MAL, "mal.call", PROGRAM_NYI);
}

str
CMDincludeFile(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{
	(void) cntxt;
	(void) mb;
	(void) stk;
	(void) pci;		/* fool compiler */
	throw(MAL, "mal.include", PROGRAM_NYI);
}
