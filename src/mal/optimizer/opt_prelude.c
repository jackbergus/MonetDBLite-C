/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0.  If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright 1997 - July 2008 CWI, August 2008 - 2018 MonetDB B.V.
 */

/*
 * opt_prelude
 * M. Kersten
 * These definitions are handy to have around in the optimizer
 */
#include "monetdb_config.h"
#include "opt_prelude.h"
#include "optimizer_private.h"

/* ! please keep this list sorted for easier maintenance ! */
str abortRef;
str actionRef;
str affectedRowsRef;
str aggrRef;
str alarmRef;
str algebraRef;
str alter_add_tableRef;
str alter_constraintRef;
str alter_del_tableRef;
str alter_functionRef;
str alter_indexRef;
str alter_roleRef;
str alter_schemaRef;
str alter_seqRef;
str alter_set_tableRef;
str alter_tableRef;
str alter_triggerRef;
str alter_typeRef;
str alter_userRef;
str alter_viewRef;
str andRef;
str antijoinRef;
str appendidxRef;
str appendRef;
str arrayRef;
str assertRef;
str attachRef;
str avgRef;
str bandjoinRef;
str basketRef;
str batalgebraRef;
str batcalcRef;
str batcapiRef;
str batmalRef;
str batmmathRef;
str batmtimeRef;
str batpyapi3Ref;
str batpyapiRef;
str batrapiRef;
str batRef;
str batsqlRef;
str batstrRef;
str batxmlRef;
str bbpRef;
str betweenRef;
str betweensymmetricRef;
str binddbatRef;
str bindidxRef;
str bindRef;
str blockRef;
str bpmRef;
str bstreamRef;
str calcRef;
str capiRef;
str catalogRef;
str clear_tableRef;
str closeRef;
str columnBindRef;
str columnRef;
str comment_onRef;
str commitRef;
str connectRef;
str copy_fromRef;
str copyRef;
str count_no_nilRef;
str countRef;
str create_constraintRef;
str create_functionRef;
str create_indexRef;
str createRef;
str create_roleRef;
str create_schemaRef;
str create_seqRef;
str create_tableRef;
str create_triggerRef;
str create_typeRef;
str create_userRef;
str create_viewRef;
str crossRef;
str dataflowRef;
str dateRef;
str dblRef;
str defineRef;
str deleteRef;
str deltaRef;
str dense_rankRef;
str dense_rankRef;
str differenceRef;
str diffRef;
str disconnectRef;
str divRef;
str drop_constraintRef;
str drop_functionRef;
str drop_indexRef;
str drop_roleRef;
str drop_schemaRef;
str drop_seqRef;
str drop_tableRef;
str drop_triggerRef;
str drop_typeRef;
str drop_userRef;
str drop_viewRef;
str emptybindidxRef;
str emptybindRef;
str eqRef;
str evalRef;
str execRef;
str expandRef;
str exportOperationRef;
str export_tableRef;
str findRef;
str finishRef;
str firstnRef;
str generatorRef;
str getRef;
str getTraceRef;
str grant_functionRef;
str grantRef;
str grant_rolesRef;
str groupbyRef;
str group_concatRef;
str groupdoneRef;
str groupRef;
str hashRef;
str hgeRef;
str identityRef;
str ifthenelseRef;
str ilikeRef;
str ilikeselectRef;
str ilikethetaselectRef;
str inplaceRef;
str intersectcandRef;
str intersectRef;
str intRef;
str ioRef;
str iteratorRef;
str jitRef;
str joinRef;
str jsonRef;
str languageRef;
str leftjoinRef;
str likeRef;
str likeselectRef;
str likethetaselectRef;
str listRef;
str lockRef;
str lookupRef;
str malRef;
str manifoldRef;
str mapiRef;
str markRef;
str matRef;
str max_no_nilRef;
str maxRef;
str mdbRef;
str mergecandRef;
str mergepackRef;
str min_no_nilRef;
str minRef;
str minusRef;
str mirrorRef;
str mitosisRef;
str mkeyRef;
str mmathRef;
str mtimeRef;
str mulRef;
str multicolumnRef;
str multiplexRef;
str mvcRef;
str newRef;
str nextRef;
str not_ilikeRef;
str not_likeRef;
str notRef;
str not_uniqueRef;
str oidRef;
str oltpRef;
str openRef;
str optimizerRef;
str pack2Ref;
str packIncrementRef;
str packRef;
str parametersRef;
str partitionRef;
str passRef;
str pcreRef;
str pinRef;
str plusRef;
str postludeRef;
str preludeRef;
str printRef;
str prodRef;
str profilerRef;
str projectdeltaRef;
str projectionpathRef;
str projectionRef;
str projectRef;
str putRef;
str pyapi3mapRef;
str pyapi3Ref;
str pyapimapRef;
str pyapiRef;
str querylogRef;
str queryRef;
str raiseRef;
str rangejoinRef;
str rankRef;
str rankRef;
str rapiRef;
str reconnectRef;
str refineRef;
str registerRef;
str register_supervisorRef;
str releaseRef;
str remapRef;
str remoteRef;
str rename_userRef;
str replaceRef;
str replicatorRef;
str resultSetRef;
str reuseRef;
str revoke_functionRef;
str revokeRef;
str revoke_rolesRef;
str rollbackRef;
str row_numberRef;
str rpcRef;
str rsColumnRef;
str sampleRef;
str schedulerRef;
str selectNotNilRef;
str selectRef;
str semaRef;
str semijoinRef;
str seriesRef;
str setAccessRef;
str setVariableRef;
str setWriteModeRef;
str singleRef;
str sinkRef;
str sliceRef;
str sortRef;
str sortReverseRef;
str sqlcatalogRef;
str sqlRef;
str startRef;
str starttraceRef;
str stopRef;
str stoptraceRef;
str streamsRef;
str strRef;
str subavgRef;
str subcountRef;
str subdeltaRef;
str subdiffRef;
str subeval_aggrRef;
str subeval_aggrRef;
str subgroupdoneRef;
str subgroupRef;
str subinterRef;
str submaxRef;
str submedianRef;
str subminRef;
str subprodRef;
str subsliceRef;
str subsumRef;
str subuniformRef;
str sumRef;
str takeRef;
str thetajoinRef;
str thetaselectRef;
str tidRef;
str timestampRef;
str transaction_abortRef;
str transaction_beginRef;
str transaction_commitRef;
str transactionRef;
str transaction_releaseRef;
str transaction_rollbackRef;
str uniqueRef;
str unlockRef;
str unpackRef;
str unpinRef;
str updateRef;
str userRef;
str vectorRef;
str wlcRef;
str wlrRef;
str zero_or_oneRef;
/* ! please keep this list sorted for easier maintenance ! */

void optimizerInit(void)
{
/* ! please keep this list sorted for easier maintenance ! */
	abortRef = putName("abort");
	actionRef = putName("action");
	affectedRowsRef = putName("affectedRows");
	aggrRef = putName("aggr");
	alarmRef = putName("alarm");
	algebraRef = putName("algebra");
	alter_add_tableRef = putName("alter_add_table");
	alter_constraintRef = putName("alter_constraint");
	alter_del_tableRef = putName("alter_del_table");
	alter_functionRef = putName("alter_function");
	alter_indexRef = putName("alter_index");
	alter_roleRef = putName("alter_role");
	alter_schemaRef = putName("alter_schema");
	alter_seqRef = putName("alter_seq");
	alter_set_tableRef = putName("alter_set_table");
	alter_tableRef = putName("alter_table");
	alter_triggerRef = putName("alter_trigger");
	alter_typeRef = putName("alter_type");
	alter_userRef = putName("alter_user");
	alter_userRef = putName("alter_user");
	alter_viewRef = putName("alter_view");
	andRef = putName("and");
	antijoinRef = putName("antijoin");
	appendidxRef = putName("append_idxbat");
	appendRef = putName("append");
	arrayRef = putName("array");
	assertRef = putName("assert");
	attachRef = putName("attach");
	avgRef = putName("avg");
	bandjoinRef = putName("bandjoin");
	basketRef = putName("basket");
	batalgebraRef = putName("batalgebra");
	batcalcRef = putName("batcalc");
	batcapiRef = putName("batcapi");
	batmalRef = putName("batmal");
	batmmathRef = putName("batmmath");
	batmtimeRef = putName("batmtime");
	batpyapi3Ref = putName("batpyapi3");
	batpyapiRef = putName("batpyapi");
	batrapiRef = putName("batrapi");
	batRef = putName("bat");
	batsqlRef = putName("batsql");
	batstrRef = putName("batstr");
	batxmlRef = putName("batxml");
	bbpRef = putName("bbp");
	betweenRef = putName("between");
	betweensymmetricRef = putName("betweensymmetric");
	binddbatRef = putName("bind_dbat");
	bindidxRef = putName("bind_idxbat");
	bindRef = putName("bind");
	blockRef = putName("block");
	bpmRef = putName("bpm");
	bstreamRef = putName("bstream");
	calcRef = putName("calc");
	capiRef = putName("capi");
	catalogRef = putName("catalog");
	clear_tableRef = putName("clear_table");
	closeRef = putName("close");
	columnBindRef = putName("columnBind");
	columnRef = putName("column");
	comment_onRef = putName("comment_on");
	commitRef = putName("commit");
	connectRef = putName("connect");
	copy_fromRef = putName("copy_from");
	copyRef = putName("copy");
	count_no_nilRef = putName("count_no_nil");
	countRef = putName("count");
	create_constraintRef = putName("create_constraint");
	create_functionRef = putName("create_function");
	create_indexRef = putName("create_index");
	createRef = putName("create");
	create_roleRef = putName("create_role");
	create_schemaRef = putName("create_schema");
	create_seqRef = putName("create_seq");
	create_tableRef = putName("create_table");
	create_triggerRef = putName("create_trigger");
	create_typeRef = putName("create_type");
	create_userRef = putName("create_user");
	create_userRef = putName("create_user");
	create_viewRef = putName("create_view");
	crossRef = putName("crossproduct");
	dataflowRef = putName("dataflow");
	dateRef = putName("date");
	dblRef = putName("dbl");
	defineRef = putName("define");
	deleteRef = putName("delete");
	deltaRef = putName("delta");
	dense_rankRef = putName("dense_rank");
	differenceRef = putName("difference");
	disconnectRef= putName("disconnect");
	divRef = putName("/");
	drop_constraintRef = putName("drop_constraint");
	drop_functionRef = putName("drop_function");
	drop_indexRef = putName("drop_index");
	drop_roleRef = putName("drop_role");
	drop_schemaRef = putName("drop_schema");
	drop_seqRef = putName("drop_seq");
	drop_tableRef = putName("drop_table");
	drop_triggerRef = putName("drop_trigger");
	drop_typeRef = putName("drop_type");
	drop_userRef = putName("drop_user");
	drop_userRef = putName("drop_user");
	drop_viewRef = putName("drop_view");
	emptybindidxRef = putName("emptybindidx");
	emptybindRef = putName("emptybind");
	eqRef = putName("==");
	evalRef = putName("eval");
	execRef = putName("exec");
	expandRef = putName("expand");
	exportOperationRef = putName("exportOperation");
	export_tableRef = putName("export_table");
	findRef = putName("find");
	finishRef = putName("finish");
	firstnRef = putName("firstn");
	generatorRef = putName("generator");
	getRef = putName("get");
	getTraceRef = putName("getTrace");
	grant_functionRef = putName("grant_function");
	grantRef = putName("grant");
	grant_rolesRef = putName("grant_roles");
	groupbyRef = putName("groupby");
	group_concatRef = putName("group_concat");
	groupdoneRef = putName("groupdone");
	groupRef = putName("group");
	hashRef = putName("hash");
	hgeRef = putName("hge");
	identityRef = putName("identity");
	ifthenelseRef = putName("ifthenelse");
	ilikeRef = putName("ilike");
	ilikeselectRef = putName("ilikeselect");
	ilikethetaselectRef = putName("ilikethetaselect");
	inplaceRef = putName("inplace");
	intersectcandRef= putName("intersectcand");
	intersectRef = putName("intersect");
	intRef = putName("int");
	ioRef = putName("io");
	iteratorRef = putName("iterator");
	jitRef = putName("jit");
	joinRef = putName("join");
	jsonRef = putName("json");
	languageRef= putName("language");
	leftjoinRef = putName("leftjoin");
	likeRef = putName("like");
	likeselectRef = putName("likeselect");
	likethetaselectRef = putName("likethetaselect");
	listRef = putName("list");
	lockRef = putName("lock");
	lookupRef = putName("lookup");
	malRef = putName("mal");
	manifoldRef = putName("manifold");
	mapiRef = putName("mapi");
	markRef = putName("mark");
	matRef = putName("mat");
	max_no_nilRef = putName("max_no_nil");
	maxRef = putName("max");
	mdbRef = putName("mdb");
	mergecandRef= putName("mergecand");
	mergepackRef= putName("mergepack");
	min_no_nilRef = putName("min_no_nil");
	minRef = putName("min");
	minusRef = putName("-");
	mirrorRef = putName("mirror");
	mitosisRef = putName("mitosis");
	mkeyRef = putName("mkey");
	mmathRef = putName("mmath");
	mtimeRef = putName("mtime");
	mulRef = putName("*");
	multicolumnRef = putName("multicolumn");
	multiplexRef = putName("multiplex");
	mvcRef = putName("mvc");
	newRef = putName("new");
	nextRef = putName("next");
	not_ilikeRef = putName("not_ilike");
	not_likeRef = putName("not_like");
	notRef = putName("not");
	not_uniqueRef= putName("not_unique");
	oidRef = putName("oid");
	oltpRef = putName("oltp");
	openRef = putName("open");
	optimizerRef = putName("optimizer");
	pack2Ref = putName("pack2");
	packIncrementRef = putName("packIncrement");
	packRef = putName("pack");
	parametersRef = putName("parameters");
	partitionRef = putName("partition");
	passRef = putName("pass");
	pcreRef = putName("pcre");
	pinRef = putName("pin");
	plusRef = putName("+");
	postludeRef = putName("postlude");
	preludeRef = putName("prelude");
	printRef = putName("print");
	prodRef = putName("prod");
	profilerRef = putName("profiler");
	projectdeltaRef = putName("projectdelta");
	projectionpathRef = putName("projectionpath");
	projectionRef = putName("projection");
	projectRef = putName("project");
	putRef = putName("put");
	pyapi3mapRef = putName("batpyapi3map");
	pyapi3Ref = putName("pyapi3");
	pyapimapRef = putName("batpyapimap");
	pyapiRef = putName("pyapi");
	querylogRef = putName("querylog");
	queryRef = putName("query");
	raiseRef = putName("raise");
	rangejoinRef = putName("rangejoin");
	rankRef = putName("rank");
	rapiRef = putName("rapi");
	reconnectRef = putName("reconnect");
	refineRef = putName("refine");
	registerRef = putName("register");
	register_supervisorRef = putName("register_supervisor");
	releaseRef = putName("release");
	remapRef = putName("remap");
	remoteRef = putName("remote");
	rename_userRef = putName("rename_user");
	replaceRef = putName("replace");
	replicatorRef = putName("replicator");
	resultSetRef = putName("resultSet");
	reuseRef = putName("reuse");
	revoke_functionRef = putName("revoke_function");
	revokeRef = putName("revoke");
	revoke_rolesRef = putName("revoke_roles");
	rollbackRef = putName("rollback");
	row_numberRef = putName("row_number");
	rpcRef = putName("rpc");
	rsColumnRef = putName("rsColumn");
	sampleRef= putName("sample");
	schedulerRef = putName("scheduler");
	selectNotNilRef = putName("selectNotNil");
	selectRef = putName("select");
	semaRef = putName("sema");
	semijoinRef = putName("semijoin");
	seriesRef = putName("series");
	setAccessRef = putName("setAccess");
	setVariableRef = putName("setVariable");
	setWriteModeRef= putName("setWriteMode");
	singleRef = putName("single");
	sinkRef = putName("sink");
	sliceRef = putName("slice");
	sortRef = putName("sort");
	sortRef = putName("sort");
	sortReverseRef = putName("sortReverse");
	sqlcatalogRef = putName("sqlcatalog");
	sqlRef = putName("sql");
	startRef = putName("start");
	starttraceRef = putName("starttrace");
	stopRef = putName("stop");
	stoptraceRef = putName("stoptrace");
	streamsRef = putName("streams");
	strRef = putName("str");
	subavgRef = putName("subavg");
	subcountRef = putName("subcount");
	subdeltaRef = putName("subdelta");
	subeval_aggrRef = putName("subeval_aggr");
	subgroupdoneRef= putName("subgroupdone");
	subgroupRef = putName("subgroup");
	submaxRef = putName("submax");
	submedianRef = putName("submedian");
	subminRef = putName("submin");
	subprodRef = putName("subprod");
	subsliceRef = putName("subslice");
	subsumRef = putName("subsum");
	subuniformRef= putName("subuniform");
	sumRef = putName("sum");
	takeRef= putName("take");
	thetajoinRef = putName("thetajoin");
	thetaselectRef = putName("thetaselect");
	tidRef = putName("tid");
	timestampRef = putName("timestamp");
	transaction_abortRef= putName("transaction_abort");
	transaction_beginRef= putName("transaction_begin");
	transaction_commitRef= putName("transaction_commit");
	transactionRef= putName("transaction");
	transaction_releaseRef= putName("transaction_release");
	transaction_rollbackRef= putName("transaction_rollback");
	uniqueRef= putName("unique");
	unlockRef= putName("unlock");
	unpackRef = putName("unpack");
	unpinRef = putName("unpin");
	updateRef = putName("update");
	userRef = putName("user");
	vectorRef = putName("vector");
	wlcRef = putName("wlc");
	wlrRef = putName("wlr");
	zero_or_oneRef = putName("zero_or_one");
/* ! please keep this list sorted for easier maintenance ! */
}
