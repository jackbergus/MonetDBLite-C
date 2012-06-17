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
 * Copyright August 2008-2012 MonetDB B.V.
 * All Rights Reserved.
*/
/*
 * MAL Instruction Trace
 * Collection of runtime statistics on specific instructions
 * is sometimes handy for post-session analysis. To accomplish
 * this, you need a small optimizer that works its way through
 * the MAL program and injects calls to your data collector.
 *
 * The example presented here can act as a template. It has
 * been designed to gather runtime information over select()
 * calls for a study on fragmentation. The collector code uses
 * the target variable to link it with the instruction of interest.
 * If optimizers decide to move things around, it can still be
 * localized at runtime.
 * @example
 * _26@{rows=31:lng@} := algebra.uselect(_22,nil:sht,2,false,false);
 * mdb.collect(_26);
 * @end example
 *
 * The result is appended to the hardwired file /tmp/MALtrace.
 * The mdb module is(should be) extended with signatures
 * to set the trace file and manipulate the trace table.
 */

#include "monetdb_config.h"
#include "opt_trace.h"

static str defaultLog;
static struct{
	str modnme,fcnnme;
	ptr modptr,fcnptr;
} monitor[]={
{"algebra","select",0,0},
{"algebra","uselect",0,0},
{0,0,0,0}
};


str
OPTtraceCall(MalBlkPtr mb, MalStkPtr stk, InstrPtr pci){
	static FILE *trace;
	str msg;
	int i,v;

	if( trace == 0){
		if( defaultLog== 0){
			char buf[PATHLENGTH];
			GDKfilepath(buf,"/tmp","MALtrace",NULL);
			defaultLog= GDKstrdup(buf);
		}

		trace= fopen(defaultLog,"a");
		if( trace == 0)
			throw(MAL, "mdb.collect", RUNTIME_FILE_NOT_FOUND);
		fprintf(trace,"#-------- \n");
		fflush(trace);
	}
	v= getArg(pci,1);
	for(i=getPC(mb,pci)-1; i>0; i--){
		pci= getInstrPtr(mb,i);
		if( getArg(pci,0) == v){
			msg= instruction2str(mb,stk,pci,LIST_MAL_DEBUG);
			fprintf(trace,"%s\n",msg);
			GDKfree(msg);
			break;
		}
	}
	return MAL_SUCCEED;
}

int 
OPTtraceImplementation(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{
	int i, k,limit,slimit;
	InstrPtr p=0, *old= mb->stmt, q;
	int actions = 0;
	str mod= putName("mdb",3);
	str fcn= putName("collect",7);

	(void) cntxt;
	(void) pci;
	(void) stk;		/* to fool compilers */

	if( monitor[0].modptr == 0)
		for(i=0; monitor[i].modnme; i++){
			monitor[i].modptr= putName(monitor[i].modnme, strlen(monitor[i].modnme));
			monitor[i].fcnptr= putName(monitor[i].fcnnme, strlen(monitor[i].fcnnme));
		}
	limit= mb->stop;
	slimit= mb->ssize;
	if ( newMalBlkStmt(mb, mb->ssize) < 0)
		return 0;

	pushInstruction(mb, old[0]);
	for (i = 1; i < limit; i++) {
		p= old[i];
		pushInstruction(mb,p);
		if( getModuleId(p) )
		for(k=0; monitor[k].modnme; k++)
		if( getModuleId(p) == monitor[k].modptr &&
			getFunctionId(p) == monitor[k].fcnptr ){
			/* inject mdb.collect(_n) */
			q= newFcnCall(mb,mod,fcn);
			pushArgument(mb,q,getArg(p,0));
			actions++;
			break;
		}
	}
	for( ; i<slimit; i++)
	if(old[i])
		freeInstruction(old[i]);
	GDKfree(old);
	return actions+i;
}
