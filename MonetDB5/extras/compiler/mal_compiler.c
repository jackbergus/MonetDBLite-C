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
 * Copyright August 2008-2011 MonetDB B.V.
 * All Rights Reserved.
 */

/*
 * @f mal_compiler
 * @a M. L. Kersten
 * @+ MAL compilation
 * Compilation of a bunch of MAL procedures can be used
 * to remove the overhead of the interpreter and reduce
 * the footprint.
 * It is particularly useful in embedded and static
 * applications.
 *
 * The current translation scheme is choosen for
 * simplicity and is particularly aimed at
 * removing the MAL interpreter overhead only.
 * The best result is most likely obtained after
 * the other MAL optimizers have performed their job.
 * This may involve code in-lining steps specifically
 * geared at producing C later on.
 *
 * To illustrate the process consider the MAL function
 * below (actual a fragment of tst903 from the test suite).
 * It contains most of the language features.
 *
 * @example
 * function tst903();
 *     b:= bat.new(:void,:lng);
 *     barrier (go,i):= language.newRange(0:lng);
 *         k:= mmath.rand();
 *         l:= calc.lng(k);
 *         bat.insert(b,nil,l);
 *         redo (go,i):= language.nextElement(1:lng,1000000:lng);
 *     exit (go,i);
 * end tst903;
 * mal.compiler("user","tst903","mal01");
 * @end example
 *
 * The C code is derived in a few steps. First the variables
 * are collected from the symbol table and turned into an
 * initialized C variable. Thereafter, we simple produce
 * function calls for each MAL instruction and plug in
 * the required flow of control statements.
 * Notice that each instruction may produce an exception,
 * which should be caught.
 *
 * Of course the resulting code is not optimal, e.g.
 * the following portion for the example is produced:
 * @example
 * str MCCuser_tst903(void *tst903)
 * {
 *         BID *b= 0; // bat[:void,:lng]
 *         void *V2= 0; // void
 *         lng V3 = 0;
 *         bit go = 0;
 *         lng i = 0;
 *         lng V6 = 0;
 *         int k = 0;
 *         lng l = 0;
 *         void *V9= 0; // void
 *         void *V10= 0; // void
 *         lng V11 = 1;
 *         lng V12 = 1000000;
 *         str Xmsg = MAL_SUCCEED;
 *         if( Xmsg = CMDBATnew(&b,&V2,&V3) ) goto wrapup;
 *         if( Xmsg = RNGnewRange_lng(&go,&i,&V6) ) goto wrapup;
 *         if(  go == 0 ||go== bit_nil ) goto EXIT_7;
 * BARRIER_3:
 *         if( Xmsg = MATHrandint(&k) ) goto wrapup;
 *         if( Xmsg = CALCint2lng(&l,&k) ) goto wrapup;
 *         if( Xmsg = BKCinsert_bun(&V9,&b,&V10,&l) ) goto wrapup;
 *         if( Xmsg = RNGnextElement_lng(&go,&i,&V11,&V12) ) goto wrapup;
 *         if( !( go == 0 ||go== bit_nil) ) goto BARRIER_3;
 * EXIT_7: ;
 * }
 * @end example
 * This models a for-loop over an integer range and
 * contains an expensive coercion.
 * One way to improve code generation is to associate
 * a code string to each MAL signature, and make
 * exception handling explicit.
 *
 * @- Limitations
 * The current implementation only handles translation
 * of command calls and multiplex statements over commands.
 * Patterns should be handled differently, e.g.  CMDBATnew
 * in the example above would make this program not
 * executable.
 */
/*
 * @-
 */
#include "monetdb_config.h"
#include "mal_compiler.h"
#include "mal_interpreter.h"
#include "mal_function.h"

static char *mccPrelude[] = {
	"/* MAL to C compiler\n",
	"   Copyright (c) 2001-July 2008, CWI.\n",
	"   Copyright (c) August 2008-2011, MonetDB B.V..\n",
	"   All rights reserved.\n",
	"*/\n",
	"#include \"monetdb_config.h\"\n",

	"#include \"atoms/blob.h\"\n",
	"#include \"atoms/color.h\"\n",
	"#include \"atoms/inet.h\"\n",
	"#include \"atoms/mtime.h\"\n",
	"#include \"atoms/streams.h\"\n",
	"#include \"atoms/str.h\"\n",
	"#include \"atoms/url.h\"\n",
	"#include \"atoms/xml.h\"\n",

	"#include \"kernel/alarm.h\"\n",
	"#include \"kernel/algebra.h\"\n",
	"#include \"kernel/array.h\"\n",
	"#include \"kernel/bat5.h\"\n",
	"#include \"kernel/batcalc.h\"\n",
	"#include \"kernel/batcast.h\"\n",
	"#include \"kernel/batifthen.h\"\n",
	"#include \"kernel/batmmath.h\"\n",
	"#include \"kernel/batmtime.h\"\n",
	"#include \"kernel/calc.h\"\n",
	"#include \"kernel/counters.h\"\n",
	"#include \"kernel/group.h\"\n",
	"#include \"kernel/microbenchmark.h\"\n",
	"#include \"kernel/mkey.h\"\n",
	"#include \"kernel/mmath.h\"\n",
	"#include \"kernel/pqueue.h\"\n",
	"#include \"kernel/status.h\"\n",

	"#include \"mal/algebraExtensions.h\"\n",
	"#include \"mal/batxml.h\"\n",
	"#include \"mal/box.h\"\n",
	"#include \"mal/bpm.h\"\n",
	"#include \"mal/clients.h\"\n",
	"#include \"mal/const.h\"\n",
	"#include \"mal/constraints.h\"\n",
	"#include \"mal/factories.h\"\n",
	"#include \"mal/inspect.h\"\n",
	"#include \"mal/language.h\"\n",
	"#include \"mal/mal_io.h\"\n",
	"#include \"mal/manual.h\"\n",
	"#include \"mal/mat.h\"\n",
	"#include \"mal/mdb.h\"\n",
	"#include \"mal/mserver.h\"\n",
	"#include \"mal/profiler.h\"\n",
	"#include \"mal/remote.h\"\n",
	"#include \"mal/sabaoth.h\"\n",
	"#include \"mal/statistics.h\"\n",
	"#include \"mal/tablet.h\"\n",
	"#include \"mal/urlbox.h\"\n",

	"#include \"mal.h\"\n",
	"#include \"mal_interpreter.h\"\n",
	"#include \"mal_function.h\"\n",

	"#define BID int\n",	/* the interface works on BAT ids */
	"#define BAT int\n",
	"#define true 1\n",
	"#define false 0\n",
	"#define nil 0\n",

	"#define RNGnewRange_lng(X,Y,Z) ((*X)=true,*(Y)= *(Z), MAL_SUCCEED)\n",
	"#define RNGnextElement_lng(X,Y,S,L) (*(Y) += *(S), *(X)= *(Y)< *(L), MAL_SUCCEED)\n",
	"#define RNGnewRange_int(X,Y,Z) ((*X)=true,*(Y)= *(Z), MAL_SUCCEED)\n",
	"#define RNGnextElement_int(X,Y,S,L) (*(Y) += *(S), *(X)= *(Y)< *(L), MAL_SUCCEED)\n",

	/* dummy to be removed later */
	"#define CALCint2lng(X,Y)  ((*X)= *(Y), MAL_SUCCEED)\n",
	0
};
static void
mccVar(stream *f, MalBlkPtr mb, int i)
{
	if (isTmpVar(mb, i))
		mnstr_printf(f, "T%d", mb->var[i]->tmpindex);
	else
		mnstr_printf(f, "%s", mb->var[i]->name);
}

static void
mccArg(stream *f, MalBlkPtr mb, int i)
{
	mnstr_printf(f, "&");
	mccVar(f, mb, i);
}

static void
mccValue(stream *f, MalBlkPtr mb, int i)
{
	int (*tostr) (str *, int *, ptr);
	str buf = 0, c;
	int sz = 0;
	ValPtr val;

	val = &getVarConstant(mb, i);
	if (val->vtype == TYPE_str) {
		mnstr_printf(f, "\"%s\"", val->val.sval);
	} else {
		tostr = BATatoms[val->vtype].atomToStr;
		(*tostr) (&buf, &sz, VALptr(val));
		c = strchr(buf, '@');
		if (c && *(c + 1) == '0')
			*c = 0;
		mnstr_printf(f, "%s", buf);
		GDKfree(buf);
	}
}

static void
mccType(stream *f, MalBlkPtr mb, int i)
{
	str tpe;

	tpe = getTypeName(getVarType(mb, i));
	if (strcmp(tpe, "void") == 0) {
		mnstr_printf(f, "void *");
	} else if (isaBatType(getVarType(mb, i))) {
		mnstr_printf(f, "int *");
	} else {
		mnstr_printf(f, "%s *", tpe);
	}
	GDKfree(tpe);
}

static void
mccInitUse(stream *f, MalBlkPtr mb)
{
	int j;
	InstrPtr p;

	p = getInstrPtr(mb, 0);
	if (p->argc > 0) {
		for (j = 0; j < p->argc; j++) {
			mnstr_printf(f, "\t(void)");
			mccVar(f, mb, getArg(p, j));
			mnstr_printf(f,";\n");
		}
	}
}
static void
mccInit(stream *f, MalBlkPtr mb)
{
	int i, j;
	InstrPtr p;

	for (i = 0; mccPrelude[i]; i++)
		mnstr_printf(f, "%s", mccPrelude[i]);
	p = getInstrPtr(mb, 0);
	mnstr_printf(f, "str MCC%s_%s(", getModuleId(p), getFunctionId(p));
	if (p->argc > 0) {
		mccType(f, mb, 0);
		mccVar(f, mb, getArg(p, 0));
		for (j = 1; j < p->argc; j++) {
			mnstr_printf(f, ",");
			mccType(f, mb, i);
			mccVar(f, mb, getArg(p, j));
		}
	}
	mnstr_printf(f, ")\n{\n");
}

static void
mccVariables(stream *f, MalBlkPtr mb)
{
	int i,j;
	str tpe, v;
	int seenbat=0;
	InstrPtr p;

	for (i = 0; i < mb->stop; i++) {
		p=getInstrPtr(mb,i);
		for(j=0;j<p->retc; j++)
		if(getVarType(mb,i)== TYPE_str){
			printf("%d %d\n",i,j);
		}
	}

	for (i = 1; i < mb->vtop; i++)
	if( !isVarTypedef(mb,i)){
		tpe = getTypeName(getVarType(mb, i));
		seenbat += isaBatType(getVarType(mb,i));
		v = getVarName(mb, i);
		if (isTmpVar(mb, i))
			*v = 'V';
		if (getVarType(mb, i) == TYPE_void) {
			mnstr_printf(f, "\tint ");
			mccVar(f, mb, i);
			mnstr_printf(f, "= 0; /* %s */\n", tpe);
		} else if (isaBatType(getVarType(mb, i))) {
			mnstr_printf(f, "\tBID ");
			mccVar(f, mb, i);
			mnstr_printf(f, "= 0; /* %s */\n", tpe);
		} else {
			mnstr_printf(f, "\t%s ", tpe);
			mccVar(f, mb, i);
			mnstr_printf(f, " = ");
			mccValue(f, mb, i);
			mnstr_printf(f, ";\n");
		}
		GDKfree(tpe);
	}
	/* if( isTmpVar(mb,i) ) GDKfree(v); */
	mnstr_printf(f, "\tstr Xmsg = MAL_SUCCEED;\n");
	/* reserve space for backups */
	if(seenbat)
		mnstr_printf(f,"\tBID *backup= (BID*) alloca(%d * sizeof(BID));\n",mb->maxarg);
}

static void
mccEntry(stream *f, MalBlkPtr mb, int i)
{
	switch (getVarType(mb, i)) {
	case TYPE_void:
		mnstr_printf(f, "1");
		break;
	case TYPE_bit:
		mccVar(f, mb, i);
		mnstr_printf(f, " == 0 ||");
		mccVar(f, mb, i);
		mnstr_printf(f, "== bit_nil");
		break;
	case TYPE_chr:
		mccVar(f, mb, i);
		mnstr_printf(f, "== chr_nil");
		break;
	case TYPE_sht:
		mccVar(f, mb, i);
		mnstr_printf(f, " < 0 ||");
		mccVar(f, mb, i);
		mnstr_printf(f, "== sht_nil");
		break;
	case TYPE_int:
		mccVar(f, mb, i);
		mnstr_printf(f, " < 0 ||");
		mccVar(f, mb, i);
		mnstr_printf(f, "== int_nil");
		break;
	case TYPE_lng:
		mccVar(f, mb, i);
		mnstr_printf(f, " < 0 ||");
		mccVar(f, mb, i);
		mnstr_printf(f, "== lng_nil");
		break;
	case TYPE_flt:
	case TYPE_dbl:
		mccVar(f, mb, i);
		mnstr_printf(f, " < 0 ||");
		mccVar(f, mb, i);
		mnstr_printf(f, "== dbl_nil");
		break;
	case TYPE_oid:
		mccVar(f, mb, i);
		mnstr_printf(f, "== oid_nil");
		break;
	case TYPE_str:
		mnstr_printf(f, " strlen(");
		mccVar(f, mb, i);
		mnstr_printf(f, ") == 0 ||");
		mccVar(f, mb, i);
		mnstr_printf(f, "== str_nil");
		break;
	default:
		mnstr_printf(f, "/* Unknown barrier :%d */", getVarType(mb, i));
	}
}

/*
 * @-
 * Before we generate code, we should check existence of
 * CATCH blocks. If they do not exist, then any exception
 * terminates the function. Otherwise, we jump to the first one.
 */
static void
mccCall(stream *f, MalBlkPtr mb, InstrPtr p, int *catch, int *ctop){
	int j;
	if (p->blk && p->blk->binding) {
		mnstr_printf(f, "\tif( (Xmsg = ");
		mnstr_printf(f, "%s(", p->blk->binding);
		mccArg(f, mb, getArg(p, 0));
		for (j = 1; j < p->argc; j++) {
			mnstr_printf(f, ",");
			mccArg(f, mb, getArg(p, j));
		}
		mnstr_printf(f, ")) )");
		if (*ctop > 0)
			mnstr_printf(f, " goto CATCH_%d;\n", catch[--*ctop]);
		else
			mnstr_printf(f, " goto wrapup;\n");
	}
}

static void
mccAssignment(stream *f, MalBlkPtr mb, InstrPtr p, int *catch, int *ctop){
	int i;
	for(i=0; i<p->retc; i++)
	if( p->retc+i <p->argc){
		mccVar(f, mb, getArg(p, i));
		mnstr_printf(f, " = ");
		if( isVarConstant(mb,getArg(p,p->retc+i-1)))
			mccValue(f,mb, getArg(p,p->retc+i-1));
		else
			mccVar(f, mb, getArg(p, p->retc+i-1));
		mnstr_printf(f, ";\n");
	}
	(void) catch;
	(void) ctop;
}

static void
mccSafeTarget(stream *f, MalBlkPtr mb, InstrPtr p, int *catch, int *ctop){
	int i;
	if( garbageControl(p)){
		for(i=0;i<p->retc; i++){
			if( isaBatType(getArgType(mb,p,i))){
				mnstr_printf(f,"\tbackup[%d]=",i);
				mccVar(f,mb,getArg(p,i));
				mnstr_printf(f,";\n");
			} else
			if( getArgType(mb,p,i)== TYPE_str){
				mnstr_printf(f,"\tbackup[%d]=strlen(",i);
				mccVar(f,mb,getArg(p,i));
				mnstr_printf(f,");\n");
				mnstr_printf(f,"\tsbackup[%d]=",i);
				mccVar(f,mb,getArg(p,i));
				mnstr_printf(f,";\n");
			}
		}
	}
	(void) catch;
	(void) ctop;
}

static void
mccRestoreTarget(stream *f, MalBlkPtr mb, InstrPtr p, int *catch, int *ctop){
	int i;
	if( garbageControl(p)){
		for(i=0;i<p->retc; i++){
			if( isaBatType(getArgType(mb,p,i))){
				mnstr_printf(f,"\tif(backup[%d] == ",i);
				mccVar(f,mb,getArg(p,i));
				mnstr_printf(f,") BBPreleaseref(backup[%d]);\n",i);
				mnstr_printf(f,"\telse BBPdecref(backup[%d],TRUE);\n",i);
			} else
			if( getArgType(mb,p,i)== TYPE_str){
				mnstr_printf(f,"\tif(backup[%d] && sbackup[%d]!= ",i,i);
				mccVar(f,mb,getArg(p,i));
				mnstr_printf(f,"\t) GDKfree(sbackup[%d]);\n",i);
			}
		}
	}
	(void) catch;
	(void) ctop;
}

static int
mccInstruction(stream *f, MalBlkPtr mb, InstrPtr p, int i, int *catch, int *ctop)
{
	int errors = 0;
	int j;

	mccSafeTarget(f,mb,p,catch,ctop);
	if (p->barrier == EXITsymbol){
		mnstr_printf(f, "EXIT_%d: ;\n", i);
		for (j = 0; j < p->retc; j++) {
			mnstr_printf(f,"\t(void)");
			mccVar(f,mb,getArg(p,j));
			mnstr_printf(f,";\n");
		}
	}

	if (p->barrier == CATCHsymbol) {
		mnstr_printf(f, "CATCH_%d:\n", i);
		mnstr_printf(f, "if( ");
		mccVar(f, mb, getArg(p, 0));
		mnstr_printf(f, " == MAL_SUCCEED) goto EXIT_%d;\n", p->jump);
		return errors;
	}

	if( p->token== ASSIGNsymbol)
		mccAssignment(f,mb,p,catch,ctop);
	else
		mccCall(f,mb,p,catch,ctop);
	if (p->barrier)
		switch (p->barrier) {
		case BARRIERsymbol:
			mnstr_printf(f, "\tif(  ");
			mccEntry(f, mb, getArg(p, 0));
			mnstr_printf(f, " ) goto EXIT_%d;\n", p->jump);
			mnstr_printf(f, "BARRIER_%d:\n", i + 1);
			break;
		case RETURNsymbol:
			for (j = 0; j < p->retc; j++) {
				mnstr_printf(f, "\tVALcopy(&");
				mccVar(f, mb, getArg(getInstrPtr(mb, 0), j));
				mnstr_printf(f, ", &");
				mccVar(f, mb, getArg(p, j));
				mnstr_printf(f, ");\n");
			}
			mnstr_printf(f, "\tgoto wrapup;\n");
		case CATCHsymbol:
		case EXITsymbol:
			break;
		case LEAVEsymbol:
		case REDOsymbol:
			mnstr_printf(f, "\tif( !( ");
			mccEntry(f, mb, getArg(p, 0));
			mnstr_printf(f, ") ) goto BARRIER_%d;\n", p->jump);
			break;
		default:
			mnstr_printf(f, "/* case not yet covered: %d */\n", p->barrier);
		}
	mccRestoreTarget(f,mb,p,catch,ctop);
	return errors;
}

/*
 * @-
 * Multiplex script calls are expanded to their code base.
 */
static void
mccMultiplex(Client cntxt, stream *f, MalBlkPtr mb, InstrPtr p)
{
	int pc = getPC(mb, p);
	InstrPtr pn;

	pn = copyInstruction(p);
	if (getFunctionId(pn))
		GDKfree(pn->fcnname);
	if (getModuleId(pn))
		setModuleId(p,NULL);
	setModuleId(pn, NULL);
	setFunctionId(pn, GDKstrdup(getVarConstant(mb, pn->argv[pn->retc]).val.sval));
	delArgument(pn, pn->retc);
	typeChecker(cntxt->nspace, mb, pn, TRUE);

	mnstr_printf(f, "{\tlng mloop;\n\tptr h,t;\n");
	mnstr_printf(f, "init todo\n");
	mnstr_printf(f, "\tif(mloop>0)\n\tdo{\n");
	mnstr_printf(f, "TODO\n");
	mccInstruction(f, mb, pn, pc, 0, 0);
	mnstr_printf(f, "\t} while(mloop > 0 );\n");
	mnstr_printf(f, "}\n");

	freeInstruction(pn);
}

static void
mccJoinPath(stream *f, MalBlkPtr mb, InstrPtr p){
	int i;
	(void)mb;
	mnstr_printf(f,"\t{ BID *j%d[]={",getArg(p,0));
	mccArg(f, mb, getArg(p, p->retc));
	for(i=p->retc+1;i<p->argc; i++){
		mnstr_printf(f,",");
		mccArg(f, mb, getArg(p, i));
	}
	mnstr_printf(f,"};\t");
	mccVar(f, mb, getArg(p,0));
	mnstr_printf(f,"= ALGjoinPathBody(%d,&j%d); ", p->argc-p->retc, getArg(p,0));
	mnstr_printf(f,"};\n");
}

static void
mccProject(stream *f, MalBlkPtr mb, InstrPtr p, int *catch, int *ctop){
	int j;
	mnstr_printf(f, "\tif( (Xmsg = ALGprojectCstBody(");
	mccArg(f, mb, getArg(p, 0));
	for (j = 1; j < p->argc; j++) {
		mnstr_printf(f, ",");
		mccArg(f, mb, getArg(p, j));
	}
	mnstr_printf(f,",%d",getArgType(mb,p,2));
	mnstr_printf(f, ")) )");
	if (*ctop > 0)
		mnstr_printf(f, " goto CATCH_%d;\n", catch[--*ctop]);
	else
		mnstr_printf(f, " goto wrapup;\n");
}
static void
mccBATnew(stream *f, MalBlkPtr mb, InstrPtr p, int *catch, int *ctop){
	mnstr_printf(f,"{");
	mnstr_printf(f,"\tint ht=%d;\n",getVarType(mb,getArg(p,1)));
	mnstr_printf(f,"\tint tt=%d;\n",getVarType(mb,getArg(p,2)));
	if(p->argc==5){
		mnstr_printf(f,"\tlng cap=");
		mccVar(f,mb,getArg(p,4));
		mnstr_printf(f,";\n");
	} else mnstr_printf(f,"\tlng cap=0;\n");
	mccSafeTarget(f,mb,p,catch,ctop);
	mnstr_printf(f, "\tif( (Xmsg = BKCnewBATlng(");
	mccArg(f, mb, getArg(p, 0));
	mnstr_printf(f, ", &ht, &tt, &cap)) )");
	if (*ctop > 0)
		mnstr_printf(f, " goto CATCH_%d;\n", catch[--*ctop]);
	else
		mnstr_printf(f, " goto wrapup;\n");
	mccRestoreTarget(f,mb,p,catch,ctop);
	mnstr_printf(f,"}\n");
}

static void
mccBody(Client cntxt, stream *f, MalBlkPtr mb)
{
	int i;
	InstrPtr p;
	int *catch, ctop = 0, errors = 0;

	catch = (int *) GDKmalloc(mb->stop);

	for (i = 1; i < mb->stop; i++) {
		p = getInstrPtr(mb, i);
		if (p->barrier == CATCHsymbol)
			catch[ctop++] = i;
	}

	for (i = 1; i < mb->stop; i++) {
		p = getInstrPtr(mb, i);
		/*
		 * @-
		 * Unfortunately, we can only compile commands now.
		 * Patterns require simulation of the context. The best
		 * approach would be to provide alternative implementations
		 * directly.
		 * A simple extension would be to also compile the dependent
		 * functions.
		 */
		if (p->token != CMDcall && getFunctionId(p)) {
			if (getModuleId(p) && getFunctionId(p) &&
				idcmp(getModuleId(p), "multiplex") == 0 &&
				idcmp(getFunctionId(p), "script") == 0) {
				mccMultiplex(cntxt,f, mb, p);
				continue;
			}
			if (getModuleId(p) && getFunctionId(p) &&
				idcmp(getModuleId(p), "algebra") == 0 &&
				idcmp(getFunctionId(p), "joinPath") == 0) {
				mccJoinPath(f, mb, p);
				continue;
			}
			if (getModuleId(p) && getFunctionId(p) &&
				idcmp(getModuleId(p), "bat") == 0 &&
				idcmp(getFunctionId(p), "new") == 0) {
				mccBATnew(f, mb, p, catch, &ctop);
				continue;
			}
			if (getModuleId(p) && getFunctionId(p) &&
				idcmp(getModuleId(p), "algebra") == 0 &&
				idcmp(getFunctionId(p), "project") == 0) {
				mccProject(f, mb, p, catch, &ctop);
				continue;
			}
#ifdef DEBUG_MAL_COMPILER
			mnstr_printf(GDKout,"call to %s.%s can not be handled correctly\n",
				getModuleId(p), getFunctionId(p));
#endif
			errors++;
		}
		errors += mccInstruction(f, mb, p, i, catch, &ctop);
	}
	GDKfree(catch);
	if (errors)
		showErrors(cntxt);
}

static void
mccExit(stream *f, MalBlkPtr mb)
{
	int i;
	mnstr_printf(f,"wrapup:;\n");
	for(i=0; i< mb->vtop; i++)
	if( isaBatType(getVarType(mb,i))
	){
		mnstr_printf(f,"\tif( ");
		mccVar(f,mb,i);
		mnstr_printf(f,"&& BBP_lrefs(");
		mccVar(f,mb,i);
		mnstr_printf(f,") ) BBPdecref(");
		mccVar(f,mb,i);
		mnstr_printf(f,",TRUE);\n");
	} else
	if( getVarType(mb,i)== TYPE_str){
		mnstr_printf(f,"\tif(");
		mccVar(f,mb,i);
		mnstr_printf(f,") GDKfree(");
		mccVar(f,mb,i);
		mnstr_printf(f,");\n");
	}
	/* handle all un-used variables
	for(i=0;i<mb->vtop; i++)
	if( !isVarUsed(mb,i)){
		mnstr_printf(f,"\t(void)");
		mccVar(f,mb,i);
		mnstr_printf(f,";\n");
	}
	*/
	mnstr_printf(f,"\treturn Xmsg;\n");
	mnstr_printf(f, "}\n");
	(void) mnstr_close(f);
}

/*
 * @-
 * The compiler is called with arguments to designate
 * the routine be expanded and the designated file.
 */
static char *codefile;

static str
mccGenerate(Client cntxt, MalBlkPtr mb, str alias)
{
	char buf[1024];
	stream *f;

	snprintf(buf, 1024, "%s/%s.c", monet_cwd, alias);
	f = open_wastream(buf);
	if (f == NULL)
		throw(IO, "optimizer.MCcompiler", "Could not access file");
	mccInit(f, mb);
	mccVariables(f, mb);
	mccInitUse(f, mb);
	mccBody(cntxt, f, mb);
	mccExit(f,mb);
	codefile= strdup(buf);
	return MAL_SUCCEED;
}

/*
 * @-
 * Dump the code produced in the standard output for ease of testing
 */
static void
mccDump(void){
	FILE *f;
	int ch;
	f= fopen(codefile,"r");
	if( f== NULL){
		printf("Could not find result file %s\n",codefile);
		return;
	}
	printf("=");
	while( (ch= fgetc(f)) != EOF ){
		printf("%c",(char)ch);
		if( ch == '\n') printf("=");
	}
}

/*
 * @-
 * The static compiler assumes constant values for the module
 * and function name,
 * The dynamic version takes variables from the runtime stack.
 */
str
MCdynamicCompiler(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr p)
{
	Symbol t;
	str alias;
	str nme, fcn, msg = MAL_SUCCEED;

	(void) mb;
	printf("Calling the dynamic compiler\n");
	nme = *(str *) getArgReference(stk, p, 1);
	fcn = *(str *) getArgReference(stk, p, 2);
	alias = *(str *) getArgReference(stk, p, 3);

#ifdef DEBUG_MAL_COMPILER
	printf("MCdynamicCompiler: %s.%s\n", nme, fcn);
#endif

	t= findSymbol(cntxt->nspace, putName(nme,strlen(nme)),fcn);
	if(t== 0)
		throw(MAL,"compiler.MALtoC","Could not find function");
	msg= mccGenerate(cntxt,t->def,alias);
#ifdef DEBUG_MAL_COMPILER
	mccDump();
#endif
	return msg;
}

str
MCloadFunction(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{
	int *ret = (int*) getArgReference(stk,pci,0);
	str *mod = (str*) getArgReference(stk,pci,1);
	str *fcn = (str*) getArgReference(stk,pci,2);
	str *fname = (str*) getArgReference(stk,pci,3);
	Symbol t;
	InstrPtr sig;
	char buf[1024];
	(void)mb;

	t= findSymbol(cntxt->nspace, putName(*mod, strlen(*mod)), *fcn);
	if(t== 0)
		throw(MAL,"compiler.load","Could not find function");
	loadLibrary(*fname,FALSE);
	snprintf(buf,1024,"MCC%s_%s", *mod,*fcn);
	sig=getInstrPtr(t->def,0);
	sig->fcn = getAddress(*fname,*mod, buf,0);
	if(sig->fcn)
		sig->token= COMMANDsymbol;
	(void) ret;
	return MAL_SUCCEED;
}

str
MCmcc(int *ret, str *fname){
	char buf[1024];

	snprintf(buf,1024,"mcc %s",*fname);
	*ret = system(buf);
	return MAL_SUCCEED;
}
