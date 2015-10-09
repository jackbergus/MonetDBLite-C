/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0.  If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright 2008-2015 MonetDB B.V.
 */

/*
 * @f opt_prelude
 * @a M. Kersten
 * These definitions are handy to have around in the optimizer
 */
#include "monetdb_config.h"
#include "opt_prelude.h"
#include "optimizer_private.h"

str abortRef;
str affectedRowsRef;
str aggrRef;
str alarmRef;
str algebraRef;
str batalgebraRef;
str appendidxRef;
str appendRef;
str assertRef;
str attachRef;
str avgRef;
str arrayRef;
str basketRef;
str batcalcRef;
str batRef;
str boxRef;
str batstrRef;
str batmtimeRef;
str batmmathRef;
str batxmlRef;
str bbpRef;
str tidRef;
str dateRef;
str deltaRef;
str subdeltaRef;
str projectdeltaRef;
str binddbatRef;
str bindidxRef;
str bindRef;
str bpmRef;
str bstreamRef;
str calcRef;
str catalogRef;
str clear_tableRef;
str closeRef;
str columnRef;
str columnBindRef;
str commitRef;
str connectRef;
str constraintsRef;
str countRef;
str subcountRef;
str copyRef;
str copy_fromRef;
str export_tableRef;
str count_no_nilRef;
str crossRef;
str createRef;
str dataflowRef;
str datacyclotronRef;
str dblRef;
str defineRef;
str deleteRef;
str depositRef;
str subdiffRef;
str subinterRef;
str mergecandRef;
str mergepackRef;
str intersectcandRef;
str eqRef;
str disconnectRef;
str evalRef;
str execRef;
str expandRef;
str exportOperationRef;
str finishRef;
str firstnRef;
str getRef;
str generatorRef;
str grabRef;
str groupRef;
str subgroupRef;
str subgroupdoneRef;
str groupbyRef;
str hgeRef;
str hashRef;
str identityRef;
str ifthenelseRef;
str inplaceRef;
str insertRef;
str intRef;
str ioRef;
str iteratorRef;
str joinPathRef;
str jsonRef;
str joinRef;
str antijoinRef;
str bandjoinRef;
str thetajoinRef;
str subjoinRef;
str subleftjoinRef;
str subantijoinRef;
str subbandjoinRef;
str subrangejoinRef;
str subthetajoinRef;
str kdifferenceRef;
str languageRef;
str leftfetchjoinRef;
str leftfetchjoinPathRef;
str likesubselectRef;
str likethetasubselectRef;
str ilikesubselectRef;
str ilikethetasubselectRef;
str likeRef;
str ilikeRef;
str not_likeRef;
str not_ilikeRef;
str listRef;
str lockRef;
str lookupRef;
str malRef;
str batmalRef;
str mapiRef;
str markRef;
str mtimeRef;
str multicolumnRef;
str matRef;
str max_no_nilRef;
str maxRef;
str submaxRef;
str submedianRef;
str mdbRef;
str min_no_nilRef;
str minRef;
str subminRef;
str mirrorRef;
str mitosisRef;
str mkeyRef;
str mmathRef;
str multiplexRef;
str manifoldRef;
str mvcRef;
str newRef;
str notRef;
str nextRef;
str oidRef;
str openRef;
str optimizerRef;
str parametersRef;
str packRef;
str pack2Ref;
str passRef;
str partitionRef;
str pcreRef;
str pinRef;
str singleRef;
str plusRef;
str minusRef;
str mulRef;
str divRef;
str printRef;
str preludeRef;
str prodRef;
str subprodRef;
str postludeRef;
str profilerRef;
str projectRef;
str putRef;
str querylogRef;
str queryRef;
str rapiRef;
str reconnectRef;
str recycleRef;
str refineRef;
str registerRef;
str remapRef;
str remoteRef;
str replaceRef;
str replicatorRef;
str resultSetRef;
str reuseRef;
str rpcRef;
str rsColumnRef;
str schedulerRef;
str selectNotNilRef;
str seriesRef;
str semaRef;
str setAccessRef;
str setWriteModeRef;
str sinkRef;
str sliceRef;
str subsliceRef;
str sortRef;
str sortReverseRef;
str sqlRef;
str srvpoolRef;
str streamsRef;
str startRef;
str stopRef;
str strRef;
str sumRef;
str subsumRef;
str subavgRef;
str subsortRef;
str takeRef;
str not_uniqueRef;
str subuniqueRef;
str unlockRef;
str unpackRef;
str unpinRef;
str updateRef;
str subselectRef;
str timestampRef;
str thetasubselectRef;
str likesubselectRef;
str ilikesubselectRef;
str userRef;
str vectorRef;
str zero_or_oneRef;

int sqlfunctionProp;

int inlineProp;
int rowsProp;
int fileProp;
int runonceProp;
int unsafeProp;
int orderDependendProp;

int hlbProp;
int hubProp;
int tlbProp;
int tubProp;
int horiginProp;		/* original oid source */
int toriginProp;		/* original oid source */
int mtProp;

void optimizerInit(void)
{
	assert(batRef == NULL);
	abortRef = putName("abort",5);
	affectedRowsRef = putName("affectedRows",12);
	aggrRef = putName("aggr",4);
	alarmRef = putName("alarm",5);
	algebraRef = putName("algebra",7);
	batalgebraRef = putName("batalgebra",10);
	appendidxRef = putName("append_idxbat",13);
	appendRef = putName("append",6);
	assertRef = putName("assert",6);
	attachRef = putName("attach",6);
	avgRef = putName("avg",3);
	arrayRef = putName("array",4);
	batcalcRef = putName("batcalc",7);
	basketRef = putName("basket",6);
	boxRef = putName("box",3);
	batstrRef = putName("batstr",6);
	batmtimeRef = putName("batmtime",8);
	batmmathRef = putName("batmmath",8);
	batxmlRef = putName("batxml",6);
	bbpRef = putName("bbp",3);
	tidRef = putName("tid",3);
	deltaRef = putName("delta",5);
	subdeltaRef = putName("subdelta",8);
	projectdeltaRef = putName("projectdelta",12);
	binddbatRef = putName("bind_dbat",9);
	bindidxRef = putName("bind_idxbat",11);
	bindRef = putName("bind",4);
	bpmRef = putName("bpm",3);
	bstreamRef = putName("bstream",7);
	calcRef = putName("calc",4);
	catalogRef = putName("catalog",7);
	clear_tableRef = putName("clear_table",11);
	closeRef = putName("close",5);
	columnRef = putName("column",6);
	columnBindRef = putName("columnBind",10);
	commitRef = putName("commit",6);
	connectRef = putName("connect",7);
	constraintsRef = putName("constraints",11);
	countRef = putName("count",5);
	subcountRef = putName("subcount",8);
	copyRef = putName("copy",4);
	copy_fromRef = putName("copy_from",9);
	export_tableRef = putName("export_table",12);
	count_no_nilRef = putName("count_no_nil",12);
	crossRef = putName("crossproduct",12);
	createRef = putName("create",6);
	dateRef = putName("date",4);
	dataflowRef = putName("dataflow",8);
	datacyclotronRef = putName("datacyclotron",13);
	dblRef = putName("dbl",3);
	defineRef = putName("define",6);
	deleteRef = putName("delete",6);
	depositRef = putName("deposit",7);
	subdiffRef = putName("subdiff",7);
	subinterRef = putName("subinter",8);
	mergecandRef= putName("mergecand",9);
	mergepackRef= putName("mergepack",9);
	intersectcandRef= putName("intersectcand",13);
	eqRef = putName("==",2);
	disconnectRef= putName("disconnect",10);
	evalRef = putName("eval",4);
	execRef = putName("exec",4);
	expandRef = putName("expand",6);
	exportOperationRef = putName("exportOperation",15);
	finishRef = putName("finish",6);
	firstnRef = putName("firstn",6);
	getRef = putName("get",3);
	generatorRef = putName("generator",9);
	grabRef = putName("grab",4);
	groupRef = putName("group",5);
	subgroupRef = putName("subgroup",8);
	subgroupdoneRef= putName("subgroupdone",12);
	groupbyRef = putName("groupby",7);
	hgeRef = putName("hge",3);
	hashRef = putName("hash",4);
	identityRef = putName("identity",8);
	ifthenelseRef = putName("ifthenelse",10);
	inplaceRef = putName("inplace",7);
	insertRef = putName("insert",6);
	intRef = putName("int",3);
	ioRef = putName("io",2);
	iteratorRef = putName("iterator",8);
	joinPathRef = putName("joinPath",8);
	joinRef = putName("join",4);
	antijoinRef = putName("antijoin",8);
	bandjoinRef = putName("bandjoin",8);
	thetajoinRef = putName("thetajoin",9);
	subjoinRef = putName("subjoin",7);
	subleftjoinRef = putName("subleftjoin",11);
	subantijoinRef = putName("subantijoin",11);
	subbandjoinRef = putName("subbandjoin",11);
	subrangejoinRef = putName("subrangejoin",12);
	subthetajoinRef = putName("subthetajoin",12);
	jsonRef = putName("json",4);
	kdifferenceRef= putName("kdifference",11);
	languageRef= putName("language",8);
	leftfetchjoinRef = putName("leftfetchjoin",13);
	leftfetchjoinPathRef = putName("leftfetchjoinPath",17);
	likesubselectRef = putName("likesubselect",13);
	ilikesubselectRef = putName("ilikesubselect",14);
	listRef = putName("list",4);
	likeRef = putName("like",4);
	ilikeRef = putName("ilike",5);
	not_likeRef = putName("not_like",8);
	not_ilikeRef = putName("not_ilike",9);
	lockRef = putName("lock",4);
	lookupRef = putName("lookup",6);
	malRef = putName("mal", 3);
	batmalRef = putName("batmal", 6);
	mapiRef = putName("mapi", 4);
	markRef = putName("mark", 4);
	mtimeRef = putName("mtime", 5);
	multicolumnRef = putName("multicolumn", 11);
	matRef = putName("mat", 3);
	max_no_nilRef = putName("max_no_nil", 10);
	maxRef = putName("max", 3);
	submaxRef = putName("submax", 6);
	submedianRef = putName("submedian", 9);
	mdbRef = putName("mdb", 3);
	min_no_nilRef = putName("min_no_nil", 10);
	minRef = putName("min", 3);
	subminRef = putName("submin", 6);
	mirrorRef = putName("mirror", 6);
	mitosisRef = putName("mitosis", 7);
	mkeyRef = putName("mkey", 4);
	mmathRef = putName("mmath", 5);
	multiplexRef = putName("multiplex", 9);
	manifoldRef = putName("manifold", 8);
	mvcRef = putName("mvc", 3);
	newRef = putName("new",3);
	notRef = putName("not",3);
	nextRef = putName("next",4);
	oidRef = putName("oid",3);
	optimizerRef = putName("optimizer",9);
	openRef = putName("open",4);
	parametersRef = putName("parameters",10);
	packRef = putName("pack",4);
	pack2Ref = putName("pack2",5);
	passRef = putName("pass",4);
	partitionRef = putName("partition",9);
	pcreRef = putName("pcre",4);
	pinRef = putName("pin",3);
	plusRef = putName("+",1);
	minusRef = putName("-",1);
	mulRef = putName("*",1);
	divRef = putName("/",1);
	printRef = putName("print",5);
	preludeRef = putName("prelude",7);
	prodRef = putName("prod",4);
	subprodRef = putName("subprod",7);
	profilerRef = putName("profiler",8);
	postludeRef = putName("postlude",8);
	projectRef = putName("project",7);
	putRef = putName("put",3);
	querylogRef = putName("querylog",8);
	queryRef = putName("query",5);
	rapiRef = putName("batrapi", 7);
	reconnectRef = putName("reconnect",9);
	recycleRef = putName("recycle",7);
	refineRef = putName("refine",6);
	registerRef = putName("register",8);
	remapRef = putName("remap",5);
	remoteRef = putName("remote",6);
	replaceRef = putName("replace",7);
	replicatorRef = putName("replicator",10);
	resultSetRef = putName("resultSet",9);
	reuseRef = putName("reuse",5);
	rpcRef = putName("rpc",3);
	rsColumnRef = putName("rsColumn",8);
	schedulerRef = putName("scheduler",9);
	selectNotNilRef = putName("selectNotNil",12);
	seriesRef = putName("series",6);
	semaRef = putName("sema",4);
	setAccessRef = putName("setAccess",9);
	setWriteModeRef= putName("setWriteMode",12);
	sinkRef = putName("sink",4);
	sliceRef = putName("slice",5);
	subsliceRef = putName("subslice",8);
	singleRef = putName("single",6);
	sortRef = putName("sort",4);
	sortReverseRef = putName("sortReverse",15);
	sqlRef = putName("sql",3);
	srvpoolRef = putName("srvpool",7);
	streamsRef = putName("streams",7);
	startRef = putName("start",5);
	stopRef = putName("stop",4);
	strRef = putName("str",3);
	sumRef = putName("sum",3);
	subsumRef = putName("subsum",6);
	subavgRef = putName("subavg",6);
	subsortRef = putName("subsort",7);
	takeRef= putName("take",5);
	timestampRef = putName("timestamp", 9);
	not_uniqueRef= putName("not_unique",10);
	subuniqueRef= putName("subunique",9);
	unlockRef= putName("unlock",6);
	unpackRef = putName("unpack",6);
	unpinRef = putName("unpin",5);
	updateRef = putName("update",6);
	subselectRef = putName("subselect",9);
	thetasubselectRef = putName("thetasubselect",14);
	likesubselectRef = putName("likesubselect",13);
	likethetasubselectRef = putName("likethetasubselect",18);
	ilikesubselectRef = putName("ilikesubselect",14);
	ilikethetasubselectRef = putName("ilikethetasubselect",19);
	vectorRef = putName("vector",6);
	zero_or_oneRef = putName("zero_or_one",11);
	userRef = putName("user",4);

	fileProp = PropertyIndex("file");
	inlineProp = PropertyIndex("inline");
	rowsProp = PropertyIndex("rows");
	runonceProp = PropertyIndex("runonce");
	unsafeProp = PropertyIndex("unsafe");
	orderDependendProp = PropertyIndex("orderdependend");
	sqlfunctionProp = PropertyIndex("sqlfunction");

	horiginProp = PropertyIndex("horigin");
	toriginProp = PropertyIndex("torigin");
	mtProp = PropertyIndex("mergetable");
	/*
	 * Set the optimizer debugging flag
	 */
	{
		int ret;
		str ref= GDKgetenv("opt_debug");
		if ( ref)
			OPTsetDebugStr(&ret,&ref);
	}

	batRef = putName("bat",3);
}
