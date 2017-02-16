/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0.  If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright 1997 - July 2008 CWI, August 2008 - 2017 MonetDB B.V.
 */

/*
 * (c) 2017 Martin Kersten
 * This module collects the workload-capture-replay statements during transaction execution,
 * also known as asynchronous logical replication management. It can be used for
 * multiple purposes: BACKUP, REPLICATION, and REPLAY
 *
 * For a BACKUP we need either a complete update log from the beginning, or
 * a binary snapshot with a collection of logs recording its changes since.
 * To ensure transaction ACID properties, the log record should be stored on
 * disk within the transaction brackets, which may cause a serious IO load.
 * (Tip, store these logs files on an SSD or NVM)
 *
 * For REPLICATION, also called a database clone or slave, we take a snapshot and the
 * log files that reflect the recent changes. The log updates are replayed against
 * the snapshot until a specific time point or transaction id is reached. 
 * 
 * Some systems also use the logical logs to REPLAY all (expensive) queries
 * against the database. We skip this for the time being, as those queries
 * can be captured already in the server.
 *
 * The goal of this module is to ease BACKUP and REPPLICATION of a master database 
 * with a time-bounded delay. This means that both master and replica run at a certain beat
 * (in seconds) by which information is made available or read by the replica.
 *
 * Such a replica in query workload sharing, database versioning, and (re-)partitioning.
 * Tables taken from the master are not protected against local updates.
 * However, any replay transaction that fails stops the cloning process.
 * Furthermore, only persistent tables are considered for replication.
 * Updates under the 'tmp' schema are ignored.
 *
 * Simplicity and ease of end-user control has been the driving argument here.
 *
 * IMPLEMENTATION
 * The underlying assumption of the techniques deployed is that the database
 * resides on a proper (global/distributed) file system to guarantees recovery 
 * from most storage system related failures, e.g. using RAID disks or LSFsystems.
 *
 * A database can be set into 'master' mode only once using the SQL command:
 * CALL master()
 * An alternative path to the log records can be given to reduce the IO latency,
 * e.g. a nearby SSD.
 * By default, it creates a directory .../dbfarm/dbname/wlc_logs to hold all 
 * necessary information for the creation of a database clone.
 *
 * A master configuration file is added to the database directory to keep the state/
 * It contains the following key=value pairs:
 * 		snapshot=<path to a snapshot directory>
 * 		logs=<path to the wlc log directory>
 * 		state=<started, stopped>
 * 		batches=<next available batch file to be applied>
 * 		beat=<maximal delay between log files, in seconds>
 * 		write=<timestamp of the last transaction recorded>
 *
 * A missing path to the snapshot denotes that we can start the clone with an empty database.
 * The log files are stored as master/<dbname>_<batchnumber>. They belong to the snapshot.
 * 
 * Each wlc log file contains a serial log of committed compound transactions.
 * The log records are represented as ordinary MAL statement blocks, which
 * are executed in serial mode. (parallelism can be considered for large updates later)
 * Each transaction job is identified by a unique id, its starting time, and the user responsible..
 * The log-record should end with a commit.
 *
 * A transaction log is created by the master using a heartbeat (in seconds).
 * A new transaction log file is published when the system has been 
 * collecting logs for some time.
 * The cycle time determines the drift of the replica, excluding its own speed to catch up.
 * The beat can be set using a SQL command, e.g.
 * CALL masterbeat(duration)
 * Setting it to zero leads to a log file per transaction and may cause a large log directory.
 * A default of 5 minutes should balance polling overhead in most practical situations.
 *
 * A minor problem here is that we should ensure that the log file is closed even if there
 * are no transactions running. It is solved with a separate monitor thread, which ensures
 * that the logs are flushed at least after 'beat' seconds since the first logrecord was created.
 * After closing, the replicas can see from the master configuration file that a new log batch is available.
 *
 * The final step is to close stop transaction logging with the command
 * CALL stopmaster().
 * It typically is the end-of-life-time for a snapshot. For example, when planning to do
 * a large bulk load of the database, stopping logging avoids a double write into the
 * database. The database can be brought back into wlc mode using a fresh snapshot.
 *
 *[TODO] A more secure way to set a database into master mode is to use the command
 *	 monetdb master <dbname> [ <optional snapshot path>]
 * which locks the database, takes a save copy, initializes the state chance to master. 
 *
 * A fresh replica can be constructed as follows:
 * 	monetdb replicate <dbname> <mastername>
 *
 * Instead of using the monetdb command line we can use the SQL calls directly
 * master() and replicate(), provided we start with a fresh database.
 *
 * CLONE
 *
 * Every clone should start off with a copy of the binary snapshot identified by 'snapshot'.
 * A fresh database can be turned into a clone using the call
 * CALL replicate('mastername')
 * It will grab the latest snapshot of the master and applies all
 * available log files before releasing the system. Progress of
 * the replication can be monitored using the -fraw option in mclient.
 * The master has no knowledge about the number of clones and their whereabouts.
 *
 * The clone process will iterate in the background through the log files, 
 * applying all update transactions.
 *
 * An optional timestamp or transaction id can be added to the replicate() command to
 * apply the logs until a given moment. This is particularly handy when an unexpected 
 * desastrous user action (drop persistent table) has to be recovered from.
 *
 * CALL replicate('mastername');
 * CALL replicate('mastername',NOW()); -- stops after we are in sink
 * ...
 * CALL replicate(NOW()); -- partial roll forward
 * ...
 * CALL replicate(); --continue nondisturbed synchronisation
 *
 * SELECT replicaClock();
 * returns the timestamp of the last replicated transaction.
 * SELECT replicaTick();
 * returns the transaction id of the last replicated transaction.
 * SELECT masterClock();
 * return the timestamp of the last committed transaction in the master.
 * SELECT masterTick();
 * return the transaction id of the last committed transaction in the master.
 *
 * Any failure encountered during a log replay terminates the replication process,
 * leaving a message in the merovingian log configuration.
 *
 * The wlc files purposely have a textual format derived from the MAL statements.
 * This provides a stepping stone for remote execution later.
 *
 * [TODO] consider the roll forward of SQL session variables, i.e. optimizer_pipe
 * For updates we don't need special care for this.
 */
#include "monetdb_config.h"
#include <time.h>
#include "mal_builder.h"
#include "wlc.h"

MT_Lock     wlc_lock MT_LOCK_INITIALIZER("wlc_lock");

static char wlc_snapshot[PATHLENGTH]; // The location of the snapshot against which the logs work
static stream *wlc_fd = 0;

// These properties are needed by the replica to direct the roll-forward.
char wlc_dir[PATHLENGTH]; 	// The location in the global file store for the logs
char wlc_name[IDLENGTH];  	// The master database name
lng   wlc_id = 0;			// next transaction id
int  wlc_state = 0;			// The current status of the in the life cycle
char wlc_write[26];			// The timestamp of the last committed transaction
int  wlc_batches = 0;		// identifier of next batch
int  wlc_beat = 10;		// maximal period covered by a single log file in seconds

/* The database snapshots are binary copies of the dbfarm/database/bat
 * New snapshots are created currently using the 'monetdb snapshot <db>' command
 * or a SQL procedure.
 *
 * The wlc logs are stored in the snapshot directory as a time-stamped list
 */

int
WLCused(void)
{
	return wlc_dir[0] != 0;
}

/* The master configuration file is a simple key=value table */
void
WLCreadConfig(FILE *fd)
{	char path[PATHLENGTH];
	while( fgets(path, PATHLENGTH, fd) ){
		path[strlen(path)-1] = 0;
		if( strncmp("logs=", path,5) == 0)
			strncpy(wlc_dir, path + 5, PATHLENGTH);
		if( strncmp("snapshot=", path,9) == 0)
			strncpy(wlc_snapshot, path + 9, PATHLENGTH);
		if( strncmp("id=", path,3) == 0)
			wlc_id = atol(path+ 3);
		if( strncmp("write=", path,6) == 0)
			strncpy(wlc_write, path + 6, 26);
		if( strncmp("batches=", path, 8) == 0)
			wlc_batches = atoi(path+ 8);
		if( strncmp("beat=", path, 5) == 0)
			wlc_beat = atoi(path+ 5);
		if( strncmp("state=", path, 6) == 0)
			wlc_state = atoi(path+ 6);
	}
	fclose(fd);
}

str
WLCgetConfig(void){
	str l;
	FILE *fd;

	l = GDKfilepath(0,0,"wlc.config",0);
	fd = fopen(l,"r");
	GDKfree(l);
	if( fd == NULL)
		throw(MAL,"wlc.getConfig","Could not access %s\n",l);
	WLCreadConfig(fd);
	return MAL_SUCCEED;
}

static 
str WLCsetConfig(void){
	str path;
	stream *fd;

	/* be aware to be safe, on a failing fopen */
	path = GDKfilepath(0,0,"wlc.config",0);
	fd = open_wastream(path);
	GDKfree(path);
	if( fd == NULL)
		throw(MAL,"wlc.setConfig","Could not access wlc.config\n");
	if( wlc_snapshot[0] )
		mnstr_printf(fd,"snapshot=%s\n", wlc_snapshot);
	mnstr_printf(fd,"logs=%s\n", wlc_dir);
	mnstr_printf(fd,"id="LLFMT"\n", wlc_id );
	mnstr_printf(fd,"write=%s\n", wlc_write );
	mnstr_printf(fd,"state=%d\n", wlc_state );
	mnstr_printf(fd,"batches=%d\n", wlc_batches );
	mnstr_printf(fd,"beat=%d\n", wlc_beat );
	close_stream(fd);
	return MAL_SUCCEED;
}

// creation of the logger file and updating the configuration file should be atomic !!!
// The log files are marked with the database name. This allows for easy recognition later on.
static str
WLCsetlogger(void)
{
	char path[PATHLENGTH];

	if( wlc_dir[0] == 0)
		throw(MAL,"wlc.setlogger","Path not initalized");
	MT_lock_set(&wlc_lock);
	snprintf(path,PATHLENGTH,"%s%c%s_%012d", wlc_dir, DIR_SEP, wlc_name, wlc_batches);
	wlc_fd = open_wastream(path);
	if( wlc_fd == 0){
		MT_lock_unset(&wlc_lock);
		GDKerror("wlc.logger:Could not create %s\n",path);
		throw(MAL,"wlc.logger","Could not create %s\n",path);
	}

	wlc_batches++;
	WLCsetConfig();
	MT_lock_unset(&wlc_lock);
	return MAL_SUCCEED;
}

/* force the current log file to its storage container */
static void
WLCcloselogger(void)
{
	if( wlc_fd == NULL)
		return ;
	mnstr_fsync(wlc_fd);
	close_stream(wlc_fd);
	wlc_fd= NULL;
	WLCsetConfig();
}

void
WLCreset(void)
{
	MT_lock_set(&wlc_lock);
	WLCcloselogger();
	wlc_snapshot[0]=0;
	wlc_dir[0]= 0;
	wlc_name[0]= 0;
	wlc_write[0] =0;
	MT_lock_unset(&wlc_lock);
}

/*
 * The WLClogger process ensures that log files are properly closed
 * and released when their cycle time window has expired.
 */

static MT_Id wlc_logger;

static void
WLClogger(void *arg)
{	 int seconds;
	(void) arg;
	while(!GDKexiting()){
		if( wlc_dir[0] && wlc_fd ){
				MT_lock_set(&wlc_lock);
				WLCcloselogger();
				MT_lock_unset(&wlc_lock);
			}
		for( seconds = 0; (wlc_beat == 0 || seconds < wlc_beat) && ! GDKexiting(); seconds++)
			MT_sleep_ms( 1000);
	}
}
/*
 * The existence of the master directory should be checked upon server restart.
 * Then the master record information should be set and the WLClogger started.
 */
str 
WLCinit(void)
{ str conf, msg= MAL_SUCCEED;

	if( wlc_state == WLC_STARTUP){
		// use default location for master configuration file
		conf = GDKfilepath(0,0,"wlc.config",0);

		if( access(conf,F_OK) ){
			GDKfree(conf);
			return MAL_SUCCEED;
		}
		GDKfree(conf);
		// we are in master mode
		strncpy(wlc_name, GDKgetenv("gdk_dbname"),IDLENGTH );
		msg =  WLCgetConfig();
		if( msg)
			GDKerror("%s",msg);
		if (MT_create_thread(&wlc_logger, WLClogger , (void*) 0, MT_THR_JOINABLE) < 0) {
                GDKerror("wlc.logger thread could not be spawned");
        }
		GDKregister(wlc_logger);
	}
	return MAL_SUCCEED;
}

str 
WLCinitCmd(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{
	(void) cntxt;
	(void) mb;
	(void) stk;
	(void) pci;
	return WLCinit();
}

str 
WLCgetmasterclock(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{	str *ret = getArgReference_str(stk,pci,0);
	(void) cntxt;
	(void) mb;
	if( wlc_write[0])
		*ret = GDKstrdup(wlc_write);
	else
		*ret = GDKstrdup(str_nil);
	return MAL_SUCCEED;
}

str 
WLCgetmastertick(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{	lng *ret = getArgReference_lng(stk,pci,0);
	(void) cntxt;
	(void) mb;
	*ret = wlc_id;
	return MAL_SUCCEED;
}

/* Changing the beat should have immediate effect
 * It forces a new log file
 */
str 
WLCsetmasterbeat(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{
	(void) mb;
	(void) cntxt;
	wlc_beat = * getArgReference_int(stk,pci,1);
	WLCcloselogger();
	return MAL_SUCCEED;
}

str 
WLCgetmasterbeat(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{	int *ret = getArgReference_int(stk,pci,0);
	(void) mb;
	(void) cntxt;
	*ret = wlc_beat;
	return MAL_SUCCEED;
}

str 
WLCmaster(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{	
	char path[PATHLENGTH];
	str l;

	(void) cntxt;
	(void) mb;
	if( wlc_state == WLC_STOP)
		throw(MAL,"master","WARNING: logging has been stopped. Use new snapshot");
	if( wlc_state == WLC_RUN)
		throw(MAL,"master","WARNING: already in master mode, call ignored");
	if( pci->argc == 2)
		strncpy(path, *getArgReference_str(stk, pci,1), PATHLENGTH);
	else{
		l = GDKfilepath(0,0,"wlc_logs",0);
		snprintf(path,PATHLENGTH,"%s%c",l, DIR_SEP);
		GDKfree(l);
	}
	// set location for logs
	if( GDKcreatedir(path) == GDK_FAIL)
		throw(SQL,"wlc.master","Could not create %s\n", path);
	strncpy(wlc_name, GDKgetenv("gdk_dbname"),IDLENGTH );
	strncpy(wlc_dir,path, PATHLENGTH);
	wlc_state= WLC_RUN;
	WLCsetConfig();
	return MAL_SUCCEED;
}

str 
WLCstopmaster(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{	
	(void) cntxt;
	(void) mb;
	(void) stk;
	(void) pci;
	if( wlc_state != WLC_RUN )
		throw(MAL,"master","WARNING: master role not active");
	wlc_state = WLC_STOP;
	WLCsetConfig();
	return MAL_SUCCEED;
}

static InstrPtr
WLCsettime(Client cntxt, InstrPtr pci, InstrPtr p)
{
	struct timeval clock;
	time_t clk ;
	struct tm ctm;
	char wlc_time[26];	

	(void) pci;
	gettimeofday(&clock,NULL);
	clk = clock.tv_sec;
	ctm = *localtime(&clk);
	strftime(wlc_time, 26, "%Y-%m-%dT%H:%M:%S",&ctm);
	return pushStr(cntxt->wlc, p, wlc_time);
}

#define WLCstart(P, K)\
{ Symbol s; \
	if( cntxt->wlc == NULL){\
		s = newSymbol("wlrc", FUNCTIONsymbol);\
		cntxt->wlc_kind = K;\
		cntxt->wlc = s->def;\
		s->def = NULL;\
	} \
	if( cntxt->wlc->stop == 0){\
		P = newStmt(cntxt->wlc,"wlr","transaction");\
		P = WLCsettime(cntxt,pci, P); \
		P = pushStr(cntxt->wlc, P, cntxt->username);\
		P->ticks = GDKms();\
}	}

str
WLCtransaction(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{
	(void) cntxt;
	(void) mb;
	(void) stk;
	(void) pci;

	return MAL_SUCCEED;
}

str
WLCquery(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{	InstrPtr p;

	(void) stk;
	if ( strcmp("-- no query",getVarConstant(mb, getArg(pci,1)).val.sval) == 0)
		return MAL_SUCCEED;	// ignore system internal queries.
	WLCstart(p, WLC_QUERY);
	p = newStmt(cntxt->wlc, "wlr","query");
	p = pushStr(cntxt->wlc, p, getVarConstant(mb, getArg(pci,1)).val.sval);
	return MAL_SUCCEED;
}

str
WLCcatalog(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{	InstrPtr p;

	(void) stk;
	WLCstart(p,WLC_CATALOG);
	p = newStmt(cntxt->wlc, "wlr","catalog");
	p = pushStr(cntxt->wlc, p, getVarConstant(mb, getArg(pci,1)).val.sval);
	return MAL_SUCCEED;
}

str
WLCchange(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{	InstrPtr p;

	(void) stk;
	WLCstart(p, WLC_UPDATE);
	p = newStmt(cntxt->wlc, "wlr","change");
	p = pushStr(cntxt->wlc, p, getVarConstant(mb, getArg(pci,1)).val.sval);
	return MAL_SUCCEED;
}

/*
 * We actually don't need the catalog operations in the log.
 * It is sufficient to upgrade the replay block to WLR_CATALOG.
 */
str
WLCgeneric(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{	InstrPtr p;
	int i, tpe, varid;
	(void) stk;
	
	WLCstart(p,WLC_IGNORE);
	p = newStmt(cntxt->wlc, "wlr",getFunctionId(pci));
	for( i = pci->retc; i< pci->argc; i++){
		tpe =getArgType(mb, pci, i);
		switch(tpe){
		case TYPE_str:
			p = pushStr(cntxt->wlc, p, getVarConstant(mb, getArg(pci, i)).val.sval);
			break;
		default:
			varid = defConstant(cntxt->wlc, tpe, getArgReference(stk, pci, i));
			p = pushArgument(cntxt->wlc, p, varid);
		}
	}
	p->ticks = GDKms();
	cntxt->wlc_kind = WLC_CATALOG;
	return MAL_SUCCEED;
}

#define bulk(TPE1, TPE2)\
{	TPE1 *p = (TPE1 *) Tloc(b,0);\
	TPE1 *q = (TPE1 *) Tloc(b, BUNlast(b));\
	int k=0; \
	for( ; p < q; p++, k++){\
		if( k % 32 == 31){\
			pci = newStmt(cntxt->wlc, "wlr",getFunctionId(pci));\
			pci = pushStr(cntxt->wlc, pci, sch);\
			pci = pushStr(cntxt->wlc, pci, tbl);\
			pci = pushStr(cntxt->wlc, pci, col);\
			pci->ticks = GDKms();\
		}\
		pci = push##TPE2(cntxt->wlc, pci ,*p);\
} }

#define updateBatch(TPE1,TPE2)\
{	TPE1 *x = (TPE1 *) Tloc(bval,0);\
	TPE1 *y = (TPE1 *) Tloc(bval, BUNlast(b));\
	int k=0; \
	for( ; x < y; x++, k++){\
		p = newStmt(cntxt->wlc, "wlr","update");\
		p = pushStr(cntxt->wlc, p, sch);\
		p = pushStr(cntxt->wlc, p, tbl);\
		p = pushStr(cntxt->wlc, p, col);\
		p = pushOid(cntxt->wlc, p,  (ol? *ol++: o++));\
		p = push##TPE2(cntxt->wlc, p ,*x);\
} }

static void
WLCdatashipping(Client cntxt, MalBlkPtr mb, InstrPtr pci, int bid)
{	BAT *b;
	str sch,tbl,col;
	(void) mb;
	b= BATdescriptor(bid);
	assert(b);

// large BATs can also be re-created using the query.
// Copy into should always be expanded, because the source may not
// be accessible in the replica. TODO

	sch = GDKstrdup(getVarConstant(cntxt->wlc, getArg(pci,1)).val.sval);
	tbl = GDKstrdup(getVarConstant(cntxt->wlc, getArg(pci,2)).val.sval);
	col = GDKstrdup(getVarConstant(cntxt->wlc, getArg(pci,3)).val.sval);
	if (cntxt->wlc_kind < WLC_UPDATE)
		cntxt->wlc_kind = WLC_UPDATE;
	switch( ATOMstorage(b->ttype)){
	case TYPE_bit: bulk(bit,Bit); break;
	case TYPE_bte: bulk(bte,Bte); break;
	case TYPE_sht: bulk(sht,Sht); break;
	case TYPE_int: bulk(int,Int); break;
	case TYPE_lng: bulk(lng,Lng); break;
	case TYPE_flt: bulk(flt,Flt); break;
	case TYPE_dbl: bulk(dbl,Dbl); break;
#ifdef HAVE_HGE
	case TYPE_hge: bulk(hge,Hge); break;
#endif
	case TYPE_str: 
		{	BATiter bi;
			BUN p,q;
			int k=0; 
			bi= bat_iterator(b);
			BATloop(b,p,q){
				if( k % 32 == 31){
					pci = newStmt(cntxt->wlc, "wlr",getFunctionId(pci));
					pci = pushStr(cntxt->wlc, pci, sch);
					pci = pushStr(cntxt->wlc, pci, tbl);
					pci = pushStr(cntxt->wlc, pci, col);
				}
				k++;
				pci = pushStr(cntxt->wlc, pci ,(str) BUNtail(bi,p));
		} }
		break;
	default:
		mnstr_printf(cntxt->fdout,"#wlc datashipping, non-supported type\n");
		cntxt->wlc_kind = WLC_CATALOG;
	}
	GDKfree(sch);
	GDKfree(tbl);
	GDKfree(col);
}

str
WLCappend(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{	 InstrPtr p;
	int tpe, varid;
	(void) stk;
	(void) mb;
	
	WLCstart(p, WLC_UPDATE);
	p = newStmt(cntxt->wlc, "wlr","append");
	p = pushStr(cntxt->wlc, p, getVarConstant(mb, getArg(pci,1)).val.sval);
	p = pushStr(cntxt->wlc, p, getVarConstant(mb, getArg(pci,2)).val.sval);
	p = pushStr(cntxt->wlc, p, getVarConstant(mb, getArg(pci,3)).val.sval);

	// extend the instructions with all values. 
	// If this become too large we can always switch to a "catalog" mode
	// forcing re-execution instead
	tpe= getArgType(mb,pci,4);
	if (isaBatType(tpe) ){
		// actually check the size of the BAT first, most have few elements
		WLCdatashipping(cntxt, mb, p, stk->stk[getArg(pci,4)].val.bval);
	} else {
		ValRecord cst;
		if (VALcopy(&cst, getArgReference(stk,pci,4)) != NULL){
			varid = defConstant(cntxt->wlc, tpe, &cst);
			p = pushArgument(cntxt->wlc, p, varid);
		}
	}
	if( cntxt->wlc_kind < WLC_UPDATE)
		cntxt->wlc_kind = WLC_UPDATE;
	
	return MAL_SUCCEED;
}

/* check for empty BATs first */
str
WLCdelete(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{	InstrPtr p;	
	int tpe, k = 0;
	int bid =  stk->stk[getArg(pci,3)].val.bval;
	oid o=0, last, *ol;
	BAT *b;
	(void) stk;
	(void) mb;
	
	b= BBPquickdesc(bid, FALSE);
	if( BATcount(b) == 0)
		return MAL_SUCCEED;
	WLCstart(p, WLC_UPDATE);
	p = newStmt(cntxt->wlc, "wlr","delete");
	p = pushStr(cntxt->wlc, p, getVarConstant(mb, getArg(pci,1)).val.sval);
	p = pushStr(cntxt->wlc, p, getVarConstant(mb, getArg(pci,2)).val.sval);
	
	tpe= getArgType(mb,pci,3);
	if (isaBatType(tpe) ){
		b= BATdescriptor(bid);
		o = b->tseqbase;
		last = o + BATcount(b);
		if( b->ttype == TYPE_void){
			for( ; o < last; o++, k++){
				if( k%32 == 31){
					p = newStmt(cntxt->wlc, "wlr","delete");
					p = pushStr(cntxt->wlc, p, getVarConstant(mb, getArg(pci,1)).val.sval);
					p = pushStr(cntxt->wlc, p, getVarConstant(mb, getArg(pci,2)).val.sval);
				}
				p = pushOid(cntxt->wlc,p, o);
			}
		} else {
			ol = (oid*) Tloc(b,0);
			for( ; o < last; o++, k++){
				if( k%32 == 31){
					p = newStmt(cntxt->wlc, "wlr","delete");
					p = pushStr(cntxt->wlc, p, getVarConstant(mb, getArg(pci,1)).val.sval);
					p = pushStr(cntxt->wlc, p, getVarConstant(mb, getArg(pci,2)).val.sval);
				}
				p = pushOid(cntxt->wlc,p, *ol);
			}
		}
		BBPunfix(b->batCacheid);
	} else
		throw(MAL,"wlc.delete","BAT expected");
	if( cntxt->wlc_kind < WLC_UPDATE)
		cntxt->wlc_kind = WLC_UPDATE;

	return MAL_SUCCEED;
}

str
WLCupdate(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{	InstrPtr p;
	str sch,tbl,col;
	ValRecord cst;
	int tpe, varid;
	oid o = 0, *ol = 0;
	
	sch = *getArgReference_str(stk,pci,1);
	tbl = *getArgReference_str(stk,pci,2);
	col = *getArgReference_str(stk,pci,3);
	WLCstart(p, WLC_UPDATE);
	tpe= getArgType(mb,pci,5);
	if (isaBatType(tpe) ){
		BAT *b, *bval;
		b= BATdescriptor(stk->stk[getArg(pci,4)].val.bval);
		bval= BATdescriptor(stk->stk[getArg(pci,5)].val.bval);
		if( b->ttype == TYPE_void)
			o = b->tseqbase;
		else
			ol = (oid*) Tloc(b,0);
		switch( ATOMstorage(bval->ttype)){
		case TYPE_bit: updateBatch(bit,Bit); break;
		case TYPE_bte: updateBatch(bte,Bte); break;
		case TYPE_sht: updateBatch(sht,Sht); break;
		case TYPE_int: updateBatch(int,Int); break;
		case TYPE_lng: updateBatch(lng,Lng); break;
		case TYPE_flt: updateBatch(flt,Flt); break;
		case TYPE_dbl: updateBatch(dbl,Dbl); break;
#ifdef HAVE_HGE
		case TYPE_hge: updateBatch(hge,Hge); break;
#endif
		case TYPE_str:
		{	BATiter bi;
			int k=0; 
			BUN x,y;
			bi = bat_iterator(bval);
			BATloop(bval,x,y){
				p = newStmt(cntxt->wlc, "wlr","update");
				p = pushStr(cntxt->wlc, p, sch);
				p = pushStr(cntxt->wlc, p, tbl);
				p = pushStr(cntxt->wlc, p, col);
				p = pushOid(cntxt->wlc, p, (ol? *ol++ : o++));
				p = pushStr(cntxt->wlc, p , BUNtail(bi,x));
				k++;
		} }
		default:
			cntxt->wlc_kind = WLC_CATALOG;
		}
		BBPunfix(b->batCacheid);
	} else {
		p = newStmt(cntxt->wlc, "wlr","update");
		p = pushStr(cntxt->wlc, p, sch);
		p = pushStr(cntxt->wlc, p, tbl);
		p = pushStr(cntxt->wlc, p, col);
		o = *getArgReference_oid(stk,pci,4);
		p = pushOid(cntxt->wlc,p, o);
		if (VALcopy(&cst, getArgReference(stk,pci,5)) != NULL){
			varid = defConstant(cntxt->wlc, tpe, &cst);
			p = pushArgument(cntxt->wlc, p, varid);
		}
	}

	if( cntxt->wlc_kind < WLC_UPDATE)
		cntxt->wlc_kind = WLC_UPDATE;
	return MAL_SUCCEED;
}

str
WLCclear_table(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{	 InstrPtr p;
	(void) stk;
	
	WLCstart(p, WLC_UPDATE);
	p = newStmt(cntxt->wlc, "wlr","clear_table");
	p = pushStr(cntxt->wlc, p, getVarConstant(mb, getArg(pci,1)).val.sval);
	p = pushStr(cntxt->wlc, p, getVarConstant(mb, getArg(pci,2)).val.sval);
	if( cntxt->wlc_kind < WLC_UPDATE)
		cntxt->wlc_kind = WLC_UPDATE;

	return MAL_SUCCEED;
}

static str
WLCwrite(Client cntxt)
{	str msg = MAL_SUCCEED;
	InstrPtr p;
	int tag;
	ValRecord cst;
	// save the wlc record on a file 
	if( cntxt->wlc == 0 || cntxt->wlc->stop <= 1 ||  cntxt->wlc_kind == WLC_QUERY )
		return MAL_SUCCEED;

	if( wlc_state != WLC_RUN){
		trimMalVariables(cntxt->wlc, NULL);
		resetMalBlk(cntxt->wlc, 0);
		cntxt->wlc_kind = WLC_QUERY;
		return MAL_SUCCEED;
	}
	if( wlc_dir[0] ){	
		if (wlc_fd == NULL){
			msg = WLCsetlogger();
			if( msg) 
				return msg;
		}
		
		p = getInstrPtr(cntxt->wlc,0);
		MT_lock_set(&wlc_lock);
		// Tag each transaction record with an unique id
		cst.vtype= TYPE_lng;
		cst.val.lval = wlc_id;
		tag = defConstant(cntxt->wlc,TYPE_lng, &cst);
		p = getInstrPtr(cntxt->wlc,0);
		p = setArgument(cntxt->wlc, p, p->retc, tag);

		// save it as an ordinary MAL block
		printFunction(wlc_fd, cntxt->wlc, 0, LIST_MAL_DEBUG );
		(void) mnstr_flush(wlc_fd);
		
		// Update wlc administration
		wlc_id++;
		strncpy(wlc_write, getVarConstant(cntxt->wlc, getArg(p, 2)).val.sval, 26);

		// close file if no delay is allowed
		if( wlc_beat == 0 )
			WLCcloselogger();

		MT_lock_unset(&wlc_lock);
		trimMalVariables(cntxt->wlc, NULL);
		resetMalBlk(cntxt->wlc, 0);
		cntxt->wlc_kind = WLC_QUERY;
	} else
			throw(MAL,"wlc.write","WLC log path missing ");

#ifdef _WLC_DEBUG_
	printFunction(cntxt->fdout, cntxt->wlc, 0, LIST_MAL_ALL );
#endif
	if( wlc_state == WLC_STOP)
		throw(MAL,"wlc.write","Logging for this snapshot has been stopped. Use a new snapshot to continue logging.");
	return msg;
}

str
WLCcommit(int clientid)
{
	if( mal_clients[clientid].wlc && mal_clients[clientid].wlc->stop > 1){
		newStmt(mal_clients[clientid].wlc,"wlr","commit");
		return WLCwrite( &mal_clients[clientid]);
	}
	return MAL_SUCCEED;
}

str
WLCcommitCmd(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{
	(void) mb;
	(void) stk;
	(void) pci;
	return WLCcommit(cntxt->idx);
}

str
WLCrollback(int clientid)
{
	if( mal_clients[clientid].wlc){
		newStmt(mal_clients[clientid].wlc,"wlr","rollback");
		return WLCwrite( &mal_clients[clientid]);
	}
	return MAL_SUCCEED;
}
str
WLCrollbackCmd(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{
	(void) mb;
	(void) stk;
	(void) pci;
	return WLCrollback(cntxt->idx);
}
