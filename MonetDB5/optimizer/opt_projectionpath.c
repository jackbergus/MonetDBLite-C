/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0.  If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright 1997 - July 2008 CWI, August 2008 - 2016 MonetDB B.V.
 */

/* author: M Kersten
 * Post-optimization of projection lists.
 * The algorithm is quadratic in the number of paths considered.
 * This should be massaged out with a skip list structure.
 */
#include "monetdb_config.h"
#include "opt_projectionpath.h"

//#undef OPTDEBUGprojectionpath 
//#define OPTDEBUGprojectionpath  if(1)

/* locate common prefixes */
static int
OPTprojectionPrefix(Client cntxt, MalBlkPtr mb, int prefixlength)
{
	int i, j, jj, k, match, actions=0;
	InstrPtr p,q,r,*old;
	int limit;

	old= mb->stmt;
	limit= mb->stop;
	if ( newMalBlkStmt(mb,mb->ssize) < 0)
		return 0;
	OPTDEBUGprojectionpath 
		mnstr_printf(cntxt->fdout,"#projectionpath find common prefix prefixlength %d \n", prefixlength);
	for( i = 0; i < limit; i++){
		match = 0;
		p= old[i];
		assert(p);
		if ( getFunctionId(p) != projectionpathRef || p->argc - p->retc < prefixlength) {
			pushInstruction(mb,p);
			continue;
		}
		/* we fixed a projection path of the target prefixlength
		 * Search now the remainder for at least one case where it
		 * has a common prefix of prefixlength 
		 */
		for( j= i+1; j < limit; j++) {
			q= old[j];
			if ( getFunctionId(q) != projectionpathRef || q->argc -  q->retc < prefixlength) 
				continue;
			for( match =0,  k = q->retc; k <  q->retc + prefixlength; k++)
				match += getArg(q,k) == getArg(p,k);
			if ( match == prefixlength )
				break;
		}
		if ( match == prefixlength ){
			/* at least one instruction has been found.
			 * Inject the prefex projection path and replace all use cases
			 */
			OPTDEBUGprojectionpath {
				mnstr_printf(cntxt->fdout,"#projectionpath found common prefix prefixlength %d \n", match);
				printInstruction(cntxt->fdout,mb, 0, p, LIST_MAL_ALL);
			}
			r = copyInstruction(p);
			r->argc=  r->retc + prefixlength;
			getArg(r,0) = newTmpVariable(mb, newBatType( TYPE_oid, getColumnType(getArgType(mb,r,r->argc-1))));
			setVarUDFtype(mb, getArg(r,0));
			if ( r->argc == 3)
				setFunctionId(r, projectionRef);
			/* First check if we already have this operation then an alias is sufficient */
			for( jj= i-1; jj > 0; jj--) {
				q= old[jj];
				if ( getFunctionId(q) != getFunctionId(r) || q->argc != r->argc) 
					continue;
				for( match =0,  k = q->retc; k < q->argc; k++)
					match += getArg(q,k) == getArg(r,k);
				if ( match ==  q->argc - q->retc){
					clrFunction(r);
					r->argc = r->retc +1;
					getArg(r,r->retc) = getArg(q,0);
					break;
				}
			}
			pushInstruction(mb,r);
			OPTDEBUGprojectionpath  {
				mnstr_printf(cntxt->fdout,"#projectionpath prefix instruction\n");
				printInstruction(cntxt->fdout,mb, 0, r, LIST_MAL_ALL);
			}

			/* patch all instructions with same prefix. */
			for( ; j < limit; j++) {
				q= old[j];
				if ( getFunctionId(q) != projectionpathRef || q->argc - q->retc < prefixlength) 
					continue;
				for( match =0,  k = q->retc; k < q->retc + prefixlength; k++)
					match += getArg(q,k) == getArg(p,k);
				if ( match == prefixlength ){
					actions++;
					OPTDEBUGprojectionpath {
						mnstr_printf(cntxt->fdout,"#projectionpath before:");
						printInstruction(cntxt->fdout,mb, 0, q, LIST_MAL_ALL);
					}
					if( prefixlength == q->argc - q->retc){
						clrFunction(q);
						getArg(q,q->retc) = getArg(r,0);
						q->argc = q->retc + 1;
					} else {
						getArg(q,q->retc) = getArg(r,0);
						for( k= 1; k < prefixlength; k++)
							delArgument(q, q->retc + 1);
						if ( q->argc == 3)
							setFunctionId(q, projectionRef);
					}
					OPTDEBUGprojectionpath {
						mnstr_printf(cntxt->fdout,"#projectionpath after :");
						printInstruction(cntxt->fdout,mb, 0, q, LIST_MAL_ALL);
					}
				}
			}
			/* patch instruction p */
			if( prefixlength == p->argc - p->retc){
				clrFunction(p);
				getArg(p,p->retc) = getArg(r,0);
				p->argc = p->retc + 1;
			} else {
				getArg(p,p->retc) = getArg(r,0);
				for( k= 1; k < prefixlength; k++)
					delArgument(q, q->retc + 1);
				if ( p->argc == 3)
					setFunctionId(p, projectionRef);
			}
			OPTDEBUGprojectionpath 
				printInstruction(cntxt->fdout,mb, 0, p, LIST_MAL_ALL);
		}
		pushInstruction(mb,p);
	}
	OPTDEBUGprojectionpath 
		mnstr_printf(cntxt->fdout,"#projectionpath prefix actions %d\n",actions);
	return actions;
}

int
OPTprojectionpathImplementation(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr p)
{
	int i,j,k, actions=0, maxprefixlength=0;
	int *pc;
	InstrPtr q,r;
	InstrPtr *old;
	int *varcnt;		/* use count */
	int limit,slimit;

	(void) cntxt;
	(void) stk;
	if ( mb->inlineProp)
		return 0;

	OPTDEBUGprojectionpath {
		mnstr_printf(cntxt->fdout,"#projectionpath optimizer start \n");
		printFunction(cntxt->fdout,mb, 0, LIST_MAL_ALL);
	}
	old= mb->stmt;
	limit= mb->stop;
	slimit= mb->ssize;
	if ( newMalBlkStmt(mb,mb->ssize + mb->stop) < 0)
		return 0;

	/* beware, new variables and instructions are introduced */
	pc= (int*) GDKzalloc(sizeof(int)* mb->vtop * 2); /* to find last assignment */
	varcnt= (int*) GDKzalloc(sizeof(int)* mb->vtop * 2); 
	if (pc == NULL || varcnt == NULL){
		if (pc ) GDKfree(pc);
		if (varcnt ) GDKfree(varcnt);
		return 0;
	}

	/*
	 * Count the variable re-use  used as arguments first.
	 */
	for (i = 0; i<limit; i++){
		p= old[i];
			for(j=p->retc; j<p->argc; j++)
				varcnt[getArg(p,j)]++;
	}

	/* assume a single pass over the plan, and only consider projection sequences 
	 * beware, we are only able to deal with projections without candidate lists. (argc=3)
	 * We also should not change the type of the outcome, i.e. leaving the last argument untouched.
 	 */
	for (i = 0; i<limit; i++){
		p= old[i];
		if( getModuleId(p)== algebraRef && getFunctionId(p) == projectionRef && p->argc == 3){
			/*
			 * Try to expand its argument list with what we have found so far.
			 */
			q= copyInstruction(p);
			OPTDEBUGprojectionpath {
				mnstr_printf(cntxt->fdout,"#before ");
				printInstruction(cntxt->fdout,mb, 0, p, LIST_MAL_ALL);
			}
			q->argc=p->retc;
			for(j=p->retc; j<p->argc; j++){
				r= getInstrPtr(mb,pc[getArg(p,j)]);
				if (r && varcnt[getArg(p,j)] > 1 ){
					/* inject the complete sub-path */
					OPTDEBUGprojectionpath {
						mnstr_printf(cntxt->fdout,"#inject ");
						printInstruction(cntxt->fdout,mb, 0, r, LIST_MAL_ALL);
					}
					r = 0;
				}
				
				if ( getFunctionId(p) == projectionRef){
					if( r &&  getModuleId(r)== algebraRef && ( getFunctionId(r)== projectionRef  || getFunctionId(r)== projectionpathRef) ){
						for(k= r->retc; k<r->argc; k++) 
							q = pushArgument(mb,q,getArg(r,k));
					} else 
						q = pushArgument(mb,q,getArg(p,j));
				}
			}
			OPTDEBUGprojectionpath {
				chkTypes(cntxt->fdout, cntxt->nspace,mb,TRUE);
				mnstr_printf(cntxt->fdout,"#new [[left]fetch]projectionpath instruction\n");
				printInstruction(cntxt->fdout,mb, 0, q, LIST_MAL_ALL);
			}
			if(q->argc<= p->argc){
				/* no change */
				freeInstruction(q);
				goto wrapup;
			}
			/*
			 * Final type check and hardwire the result type, because that  can not be inferred directly from the signature
			 * We already know that all heads are void. Only the last element may have a non-oid type.
			 */
			for(j=1; j<q->argc-1; j++)
				if( getColumnType(getArgType(mb,q,j)) != TYPE_oid  && getColumnType(getArgType(mb,q,j)) != TYPE_void ){
					/* don't use the candidate list */
					freeInstruction(q);
					goto wrapup;
				}

			/* fix the type */
			setVarUDFtype(mb, getArg(q,0));
			setVarType(mb, getArg(q,0), newBatType( TYPE_oid, getColumnType(getArgType(mb,q,q->argc-1))));
			if ( getFunctionId(q) == projectionRef )
				setFunctionId(q,projectionpathRef);
			OPTDEBUGprojectionpath {
				mnstr_printf(cntxt->fdout,"#after ");
				printInstruction(cntxt->fdout,mb, 0, q, LIST_MAL_ALL);
			}
			freeInstruction(p);
			p= q;
			/* keep track of the longest projection path */
			if ( p->argc  > maxprefixlength)
				maxprefixlength = p->argc;
			actions++;
		} 
	wrapup:
		pushInstruction(mb,p);
		for(j=0; j< p->retc; j++)
			pc[getArg(p,j)]= mb->stop-1;
		OPTDEBUGprojectionpath {
			mnstr_printf(cntxt->fdout,"#keep ");
			printInstruction(cntxt->fdout,mb, 0, p, LIST_MAL_ALL);
		}
	}
	OPTDEBUGprojectionpath 
		mnstr_printf(cntxt->fdout,"#projection path prefixlength %d\n",maxprefixlength);

	for(; i<slimit; i++)
		if(old[i])
			freeInstruction(old[i]);
	GDKfree(old);
	GDKfree(pc);
	if (varcnt ) GDKfree(varcnt);

	/* All complete projection paths have been constructed.
	 * There may be cases where there is a common prefix used multiple times.
	 * There are located and removed in a few scans over the plan
	 */
	if(0)
	for( ; maxprefixlength >= 2; maxprefixlength--)
		actions += OPTprojectionPrefix(cntxt, mb, maxprefixlength);
	OPTDEBUGprojectionpath {
		mnstr_printf(cntxt->fdout,"#projectionpath optimizer result \n");
		printFunction(cntxt->fdout,mb, 0, LIST_MAL_ALL);
	}
	return actions;
}
