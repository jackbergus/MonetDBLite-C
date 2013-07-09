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
/* (c) M. Ivanova, M. Kersten
 * Determine the instructions to be handled by the recycler.
 *
 * Instructions that break the linear flow also stop further
 * recycling. This does not hold for dataflow blocks.
 * Update statements are not recycled. They trigger cleaning of
 * the recycle cache.
 * Each variable be trigger a recycling action only once
 */
#include "monetdb_config.h"
#include "opt_recycler.h"
#include "opt_dataflow.h"
#include "mal_instruction.h"

static int isFunctionArgument(MalBlkPtr mb, int varid){
	int i;
	InstrPtr p = getInstrPtr(mb,0);
	for ( i=p->retc; i<p->argc; i++)
		if ( getArg(p,i) == varid) 
			return TRUE;
	return FALSE;
}

int
OPTrecyclerImplementation(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{
	int i, j, cnt, cand, actions = 1, marks = 0;
	InstrPtr *old, q,p;
	int limit;
	char *recycled;

	(void) cntxt;
	(void) stk;
	(void) pci;

	limit = mb->stop;
	old = mb->stmt;

	/* watch out, newly created instructions may introduce new variables */
	recycled = GDKzalloc(sizeof(char) * mb->vtop * 2);
	if (recycled == NULL)
		return 0;
	if (newMalBlkStmt(mb, mb->ssize) < 0) {
		GDKfree(recycled);
		return 0;
	}
	pushInstruction(mb, old[0]);
	/* create a handle for the recycler */
	(void) newFcnCall(mb, "recycle", "start");
	for (i = 1; i < limit; i++) {
		p = old[i];
		if (p->token == ENDsymbol ){
			(void) newFcnCall(mb, "recycle", "stop");
			break;
		}
		if (p->barrier == RETURNsymbol) 
			(void) newFcnCall(mb, "recycle", "stop");
		/* the first non-dataflow barrier breaks the recycler code*/
		if (blockStart(p) && !(getFunctionId(p) && getFunctionId(p) == dataflowRef) ){
			(void) newFcnCall(mb, "recycle", "stop");
			break;
		}

		if ( isUpdateInstruction(p) || hasSideEffects(p,TRUE)){
			/*  update instructions are not recycled but monitored*/
			pushInstruction(mb, p);
			if (isUpdateInstruction(p)) {
				if (getModuleId(p) == batRef && isaBatType(getArgType(mb, p, 1))) {
					recycled[getArg(p, 1)] = 0;
					q = newFcnCall(mb, "recycle", "reset");
					pushArgument(mb, q, getArg(p, 0));// to keep dataflow dependency
					pushArgument(mb, q, getArg(p, 1));
					actions++;
				}
				if (getModuleId(p) == sqlRef) {
					q = newFcnCall(mb, "recycle", "reset");
					pushArgument(mb, q, getArg(p, 0));// to keep dataflow dependency
					pushArgument(mb, q, getArg(p, 2));
					pushArgument(mb, q, getArg(p, 3));
					actions++;
				}
			}
			continue;
		}

		/* general rule: all arguments should be constants or recycled*/
		cnt = 0;
		for (j = p->retc; j < p->argc; j++)
			if (recycled[getArg(p, j)] || isVarConstant(mb, getArg(p, j)) || isFunctionArgument(mb,getArg(p,j)) )
				cnt++;
		cand = 0;
		for (j =0; j< p->retc; j++)
			if (recycled[getArg(p, j)] ==0)
				cand++;
		if (cnt == p->argc - p->retc && cand == p->retc) {
			//OPTDEBUGrecycle {
				mnstr_printf(cntxt->fdout, "#recycle instruction: ");
				printInstruction(cntxt->fdout, mb, 0, p, LIST_MAL_DEBUG);
			//}
			marks++;
			p->recycle = recycleMaxInterest; /* this instruction is to be monitored */
			for (j = 0; j < p->retc; j++)
				recycled[getArg(p, j)] = 1;
		}
		pushInstruction(mb, p);
	}
	for (; i < limit; i++) 
		pushInstruction(mb, old[i]);
	GDKfree(old);
	GDKfree(recycled);
	mb->recycle = marks > 0;
	return actions + marks;
}
