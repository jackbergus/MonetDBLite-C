/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0.  If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright 2008-2015 MonetDB B.V.
 */

/* author: M Kersten
 * Progress indicator
 * tachograph -d demo 
 * which connects to the demo database server and presents a server progress bar.
*/

#include "monetdb_config.h"
#include "monet_options.h"
#include <mapi.h>
#include <stream.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <errno.h>
#include <signal.h>
#include <math.h>
#include <unistd.h>
#include "mprompt.h"
#include "dotmonetdb.h"
#include "eventparser.h"

#ifndef HAVE_GETOPT_LONG
# include "monet_getopt.h"
#else
# ifdef HAVE_GETOPT_H
#  include "getopt.h"
# endif
#endif

#ifdef TIME_WITH_SYS_TIME
# include <sys/time.h>
# include <time.h>
#else
# ifdef HAVE_SYS_TIME_H
#  include <sys/time.h>
# else
#  include <time.h>
# endif
#endif
#ifdef NATIVE_WIN32
#include <direct.h>
#endif

#define die(dbh, hdl)						\
	do {							\
		(hdl ? mapi_explain_query(hdl, stderr) :	\
		 dbh ? mapi_explain(dbh, stderr) :		\
		 fprintf(stderr, "!! command failed\n"));	\
		goto stop_disconnect;				\
	} while (0)

#define doQ(X)								\
	do {								\
		if ((hdl = mapi_query(dbh, X)) == NULL ||	\
		    mapi_error(dbh) != MOK)			\
			die(dbh, hdl);			\
	} while (0)

static stream *conn = NULL;
static char hostname[128];
static char *basefilename = "tachograph";
static char *cache= "cache";
static char *dbname;
static int beat = 5000;
static int delay = 0; // ms
static Mapi dbh;
static MapiHdl hdl = NULL;
static int interactive = 1;
static int capturing=0;
static int lastpc;
static int pccount;

#define RUNNING 1
#define FINISHED 2
typedef struct{
	int state;
	lng etc;
	lng actual;
	char *stmt;
} Event;

Event *events;

typedef struct {
	char *varname;
	char *source;
} Source;
Source *sources;	// original column name
int srctop, srcmax;

static void
addSource(char *varname, char *tbl, char *col)
{
	char buf[BUFSIZ];

	if(srctop == srcmax){
		if( srcmax == 0)
			sources = (Source *) malloc(2048 * sizeof(Source));
		else
			sources = (Source *) realloc(sources, srcmax+2048);
		srcmax+= 2048;
	}
	assert(sources);
	sources[srctop].varname = strdup(varname);
	snprintf(buf,BUFSIZ,"%s%s%s",tbl,(col?".":""),col?col:"");
	sources[srctop].source = strdup(buf);
	//fprintf(stderr,"addSource %s at %d  %s\n",varname, srctop, buf);
	srctop++;
}

static void
addSourcePair(char *varname, char *name)
{
	int i;

	if(srctop == srcmax){
		if( srcmax == 0)
			sources = (Source *) malloc(1024 * sizeof(Source));
		else
			sources = (Source *) realloc((void *)sources, (srcmax+1024) * sizeof(Source));
		srcmax+= 1024;
	}
	for( i=0; i< srctop; i++)
	if( strcmp(name, sources[i].varname)==0){
		sources[srctop].varname = strdup(varname);
		sources[srctop].source = strdup(sources[i].source);
		//fprintf(stderr,"addSourcePair %s  %s\n",varname,sources[i].source);
		srctop++;
		return;
	}
}
static char *
fndSource(char *varname)
{
	int i;

	if(debug)
		fprintf(stderr,"fndSource %s\n",varname);
	for( i=0; i< srctop; i++)
	if( strcmp(varname, sources[i].varname)==0)
		return strdup(sources[i].source);
	return strdup(varname);
}
/*
 * Parsing the argument list of a MAL call to obtain un-quoted string values
 */

static void
usageTachograph(void)
{
    fprintf(stderr, "tachograph [options] \n");
    fprintf(stderr, "  -d | --dbname=<database_name>\n");
    fprintf(stderr, "  -u | --user=<user>\n");
    fprintf(stderr, "  -p | --port=<portnr>\n");
    fprintf(stderr, "  -h | --host=<hostname>\n");
	fprintf(stderr, "  -b | --beat=<delay> in milliseconds (default 5000)\n");
	fprintf(stderr, "  -i | --interactive=<o | 1> show trace on stdout\n");
    fprintf(stderr, "  -o | --output=<webfile>\n");
    fprintf(stderr, "  -w | --wait=<delay time> in milliseconds\n");
    fprintf(stderr, "  -? | --help\n");
	exit(-1);
}

/* Any signal should be captured and turned into a graceful
 * termination of the profiling session. */

static void
stopListening(int i)
{
	fprintf(stderr,"signal %d received\n",i);
	if( dbh)
		doQ("profiler.stop();");
stop_disconnect:
	// show follow up action only once
	if(dbh)
		mapi_disconnect(dbh);
	exit(0);
}

char *currentfunction= 0;
char *currentquery= 0;
int currenttag;		// to distinguish query invocations
lng starttime = 0;
lng finishtime = 0;
lng duration =0;
int malsize = 0;
char *prevquery= 0;
int prevprogress =0;
int prevlevel =0; 
size_t txtlength=0;

// limit the number of separate queries in the pool
#define QUERYPOOL 32
int queryid= 0;

static FILE *tachojson;
static FILE *tachotrace;

static void resetTachograph(void){
	int i;
	if (debug)
		fprintf(stderr, "RESET tachograph\n");
	if( prevprogress)
		printf("\n"); 
	for(i=0; i < malsize; i++)
	if( events[i].stmt)
		free(events[i].stmt);
	for(i=0; i< srctop; i++){
		free(sources[i].varname);
		free(sources[i].source);
	}
	srctop=0;
	malsize= 0;
	malargtop =0;
	currentfunction = 0;
	currenttag = 0;
	currentquery = 0;
	starttime = 0;
	finishtime = 0;
	duration =0;
	fclose(tachojson);
	tachojson = 0;
	fclose(tachotrace);
	tachotrace = 0;
	prevprogress = 0;
	txtlength =0;
	prevlevel=0;
	lastpc = 0;
	pccount = 0;
	fflush(stdout);
	events = 0;
	queryid = (queryid+1) % QUERYPOOL;
}

static char stamp[BUFSIZ]={0};
static void
rendertime(lng ticks, int flg)
{
	int t, hr,min,sec;

	if( ticks == 0){
		strcpy(stamp,"unknown ");
		return;
	}
	t = (int) (ticks/1000000);
	sec = t % 60;
	min = (t /60) %60;
	hr = (t /3600);
	if( flg)
	snprintf(stamp,BUFSIZ,"%02d:%02d:%02d.%06d", hr,min,sec, (int) ticks %1000000); 
	else
	snprintf(stamp,BUFSIZ,"%02d:%02d:%02d", hr,min,sec); 
}

#define MSGLEN 100

/*
 * Render the output of the stethoscope into a more user-friendly format.
 * This involves removal of MAL variables and possibly renaming the MAL functions
 * by more general alternatives.
 * If mode is set then we go for a minimal base-table related display
 */
static struct{
	char *name;
	int length;
	char *alias;
	int newl;
	int mode;
}mapping[]={
	{"algebra.leftfetchjoinPath", 25, "join",4, 0},
	{"algebra.thetasubselect", 22, "select",6, 0},
	{"algebra.leftfetchjoin", 21, "join",4, 0},
	{"dataflow.language", 17,	"parallel", 8, 0},
	{"algebra.subselect", 17, "select",6, 0},
	{"sql.projectdelta", 16, "project",7, 0},
	{"algebra.subjoin", 15, "join",4, 0},
	{"language.pass(nil)", 18,	"pass", 4, 0},
	{"mat.packIncrement", 17, "pack",4, 0},
	{"language.pass", 13,	"pass", 4, 0},
	{"aggr.subcount", 13,	"count", 5, 0},
	{"sql.subdelta", 12, "project",7, 0},
	{"bat.append", 10,	"append", 6, 0},
	{"aggr.subavg", 11,	"average", 7, 0},
	{"aggr.subsum", 11,	"sum", 3, 0},
	{"aggr.submin", 11,	"minimum", 7, 0},
	{"aggr.submax", 11,	"maximum", 7, 0},
	{"aggr.count", 10,	"count", 5, 0},
	{"calc.lng", 8,	"long", 4, 0},
	{"sql.bind", 8,	"bind", 4, 0},
	{"batcalc.hge", 11, "hugeint", 7, 0},
	{"batcalc.dbl", 11, "real", 4, 0},
	{"batcalc.flt", 11, "real", 4, 0},
	{"batcalc.lng", 11, "bigint",6, 0},
	{"batcalc.", 8, "", 0, 0},
	{"calc.", 5, "", 0, 0},
	{"sql.", 4,	"", 0, 0},
	{"bat.", 4,	"", 0, 0},
	{"aggr.", 5,	"", 0, 0},
	{"group.sub", 9,	"", 0, 0},
	{"group.", 6,	"", 0, 0},
	{"mtime.", 6,	"", 0, 0},
	{0,0,0,0,0}};

static void
renderArgs(char *c, int len,  char *line, char *limit, char *l)
{
	char varname[BUFSIZ]={0}, *v=0;
	for(; *c && *c !=')' && l < limit-1; ){
		if( *c == ',')*l++= *c++;
		v= 0;
		if(isalpha((int)*c) || *c == '_' ){ 
			v= varname;
			while(*c && (isalnum((int)*c) || *c=='_')) *v++ = *c++;
			*v=0;
		}
		if( *c == '=') c++;
		if( *c == '<'){
			while(*c && *c !='>') c++;
			if(*c) c++;
			if (v && varname[0]){
				v= fndSource(varname);
				snprintf(l, len -strlen(line)-2,"%s",v);
				while(*l) l++;
				free(v);
			}
			while(*c && *c !=']' && l < limit -2) *l++ = *c++;
			while(*c && *c != ']') c++;
			if( *c == ']' ) *l++ = *c++;
		}
		if (*c == '"' ) {
			*l++ = *c++;
			while(*c && *c !='"' && *(c-1) !='\\' && l < limit-2 ) *l++ =*c++;
			while(*c && *c !='"') c++;
		}  else{
			while(*c && *c !=':' && *c !=',' && l < limit-2) *l++ = *c++;
			while(*c && *c !=':' && *c !=',' )  c++;
		}
		if (*c == ':'){
			if( strncmp(c,":bat",4)== 0){
				while(*c && *c !=']') c++;
				if( *c == ']') c++;
			} else
				while(*c && *c != ',' && *c != ')') c++;
		}
		// literals
		if( strcmp(varname,"nil") == 0 || strcmp(varname,"true")==0 || strcmp(varname,"false")==0)
			for(v = varname; *v; ) *l++ = *v++;
	}
	if(*c) *l++ = *c;
	*l=0;
}

static void
renderCall(char *line, int len, char *stmt, int state, int mode)
{
	char *limit= line + len, *l = line, *c = stmt, *s;
	int i;

	(void) state;
	// look for assignment
	c = strstr(c," :=");
	if( c) {
		if(state){
			// for finished instructions show the result too
			*c =0;
			s = stmt;
			while(*s && isspace((int) *s)) s++;
			if( *s == '(') *l++ = *s++;
			renderArgs(s, len, line, limit, l);
			while(*l) l++;
			sprintf(l," := ");
			while(*l) l++;
		}
		c+=3;
	 } else c=stmt;

	while ( *c && isspace((int) *c)) c++;
	/* consider a function name remapping */
	if( mode){
		for(i=0; mapping[i].name; i++)
			if( strncmp(c,mapping[i].name, mapping[i].length) == 0){
				c+= mapping[i].length;
				sprintf(l,"%s",  mapping[i].alias);
				l += mapping[i].newl;
				*l=0;
				break;
			}
		while(*c && *c !='(') *l++= *c++;
	}  else
		while(*c && *c !='(') *l++= *c++;
	// handle argument list
	if( *c == '(') *l++ = *c++;
	renderArgs(c, len, line, limit, l);
}

static void
showBar(int level, lng clk, char *stmt)
{
	lng i =0, nl;
	size_t stamplen=0;
	char line[BUFSIZ]={0};

	nl = level/2-prevlevel/2;
	if(nl == 0 ||  level/2 <= prevlevel/2)
		return;
	assert(MSGLEN < BUFSIZ);
	if(prevlevel == 0)
		printf("[");
	else
	for( i= 50 - prevlevel/2 +txtlength; i>0; i--)
		printf("\b \b");
	for( i=0 ; i< nl ; i++)
		putchar('#');
	for( ; i < 50-prevlevel/2; i++)
		putchar('.');
	putchar(level ==100?']':'>');
	printf(" %3d%%",level);
	if( level == 100 || duration == 0){
		rendertime(clk,0);
		printf("  %s      ",stamp);
		stamplen= strlen(stamp)+3;
	} else
	if( duration && duration- clk > 0){
		rendertime(duration - clk,0);
		printf(" %c%s ETC  ", (level == 100? '-':' '),stamp);
		stamplen= strlen(stamp)+3;
	} else
	if( duration && duration- clk < 0){
		rendertime(clk - duration ,0);
		printf(" +%s ETC  ",stamp);
		stamplen= strlen(stamp)+3;
	} 
	renderCall(line,MSGLEN,(stmt?stmt:""),0,1);
	printf("%s",line);
	fflush(stdout);
	txtlength = 11 + stamplen + strlen(line);
	prevlevel = level;
}

/* create the progressbar JSON file for pickup.
 * Keep the file in the pool, together with its original trace
 */

static void
initFiles(void)
{
	char buf[BUFSIZ];

	if (cache)
#ifdef NATIVE_WIN32
		snprintf(buf,BUFSIZ,"%s\\%s_%s_%d.json",cache,basefilename,dbname, queryid);
#else
		snprintf(buf,BUFSIZ,"%s/%s_%s_%d.json",cache,basefilename,dbname, queryid);
#endif
	else 
		snprintf(buf,BUFSIZ,"%s_%s_%d.json",basefilename,dbname, queryid);
	tachojson= fopen(buf,"w");
	if( tachojson == NULL){
		fprintf(stderr,"Could not create %s\n",buf);
		exit(0);
	}
	if (cache)
#ifdef NATIVE_WIN32
		snprintf(buf,BUFSIZ,"%s\\%s_%s_%d.trace",cache,basefilename,dbname, queryid);
#else
		snprintf(buf,BUFSIZ,"%s/%s_%s_%d.trace",cache,basefilename,dbname, queryid);
#endif
	else 
		snprintf(buf,BUFSIZ,"%s_%s_%d.trace",basefilename,dbname, queryid);
	tachotrace= fopen(buf,"w");
	if( tachotrace == NULL){
		fprintf(stderr,"Could not create %s\n",buf);
		exit(0);
	}
	if( monet_characteristics)
		fprintf(tachotrace,"%s\n",monet_characteristics);
}

static void
progressBarInit(char *qry)
{
	fprintf(tachojson,"{ \"tachograph\":0.1,\n");
	fprintf(tachojson," \"qid\":\"%s\",\n",currentfunction?currentfunction:"");
	fprintf(tachojson," \"tag\":\"%d\",\n",currenttag);
	fprintf(tachojson," \"query\":\"%s\",\n",qry);
	fprintf(tachojson," \"started\": "LLFMT",\n",starttime);
	fprintf(tachojson," \"duration\":"LLFMT",\n",duration);
	fprintf(tachojson," \"instructions\":%d\n",malsize);
	fprintf(tachojson,"},\n");
	fflush(tachojson);
}

static void
update(EventRecord *ev)
{
	int progress=0;
	int i,j;
	char *v, *qry, *q = 0, *c;
	int uid = 0,qid = 0;
	char line[BUFSIZ];
	char prereq[BUFSIZ]={0};
	char number[BUFSIZ]={0};
 
	/* handle a ping event, keep the current instruction in focus */
	if (ev->state >= PING ) {
		// All state events are ignored
		return;
	}

	if (debug)
		fprintf(stderr, "Update %s input %s stmt %s time " LLFMT"\n",(ev->state>=0?statenames[ev->state]:"unknown"),(ev->fcn?ev->fcn:"(null)"),(currentfunction?currentfunction:""),ev->clkticks -starttime);

	if (starttime == 0) {
		if (ev->fcn == 0 ) {
			if (debug)
				fprintf(stderr, "Skip %s input %s\n",(ev->state>=0?statenames[ev->state]:"unknown"),ev->fcn);
			return;
		}
		if (debug)
			fprintf(stderr, "Start capturing updates %s\n",ev->fcn);
	}
	if (ev->clkticks < 0) {
		/* HACK: *TRY TO* compensate for the fact that the MAL
		 * profiler chops-off day information, and assume that
		 * clkticks is < starttime because the tomograph run
		 * crossed a day boundary (midnight);
		 * we simply add 1 day (24 hours) worth of microseconds.
		 * NOTE: this surely does NOT work correctly if the
		 * tomograph run takes 24 hours or more ...
		 */
		ev->clkticks += US_DD;
	}

	/* monitor top level function brackets, we restrict ourselves to SQL queries */
	if (!capturing && ev->state == START && ev->fcn && strncmp(ev->fcn, "function", 8) == 0) {
		if( (i = sscanf(ev->fcn + 9,"user.s%d_%d",&uid,&qid)) != 2){
			if( debug)
				fprintf(stderr,"Start phase parsing %d, uid %d qid %d\n",i,uid,qid);
			return;
		}
		if (capturing++ == 0){
			starttime = ev->clkticks;
			finishtime = ev->clkticks + ev->ticks;
			duration = ev->ticks;
		}
		if (currentfunction == 0){
			currentfunction = strdup(ev->fcn+9);
			currenttag = ev->tag;
		}
		if (debug)
			fprintf(stderr, "Enter function %s capture %d\n", currentfunction, capturing);
		initFiles();
		return;
	}
	ev->clkticks -= starttime;

	if ( !capturing)
		return;

	/* start of instruction box */
	if (ev->state == START ) {
		if(ev->fcn && strstr(ev->fcn,"querylog.define") ){
			// extract a string argument
			currentquery = malarguments[0];
			malsize = malarguments[2]? atoi(malarguments[2]): 2048;
			events = (Event*) malloc(malsize * sizeof(Event));
			memset((char*)events, 0, malsize * sizeof(Event));
			// use the truncated query text, beware that the \ is already escaped in the call argument.
			q = qry = (char *) malloc(strlen(currentquery) * 2);
			for (c= currentquery; *c; ){
				if ( strncmp(c,"\\\\t",3) == 0){
					*q++ = '\t';
					c+=3;
				} else
				if ( strncmp(c,"\\\\n",3) == 0){
					*q++ = '\n';
					c+=3;
				} else if ( strncmp(c,"\\\\",2) == 0){
					c+= 2;
				} else *q++ = *c++;
			}
			*q =0;
			currentquery = qry;
			if( ! (prevquery && strcmp(currentquery,prevquery)== 0) && interactive )
				printf("%s\n",qry);
			prevquery = currentquery;
			progressBarInit(qry);
		}
		if( ev->tag != currenttag)
			return;	// forget all except one query
		assert(ev->pc < malsize);
		events[ev->pc].state = RUNNING;
		renderCall(line,BUFSIZ, ev->stmt,0,1);
		events[ev->pc].stmt = strdup(ev->stmt);
		events[ev->pc].etc = ev->ticks;
		if( ev->pc > lastpc)
			lastpc = ev->pc;
		// keep track of sources, pick first variable only
		// We should use the MAL semantics to pick to proper heritage path
		if ( strstr(ev->stmt,"sql.tid") && *ev->stmt != '('){
			char nme[BUFSIZ],*n=nme, *s= ev->stmt;
			while(*s && *s != '=') *n++ = *s++;
			*n = 0;
			addSource(nme, malarguments[2], "");
		} else 
		if ( strstr(ev->stmt,"sql.bind") && *ev->stmt != '('){
			char nme[BUFSIZ],*n=nme, *s= ev->stmt;
			while(*s && *s != '=') *n++ = *s++;
			*n = 0;
			addSource(nme, malarguments[2], malarguments[3]);
		} else
		if ( strstr(ev->stmt,"sql.projectdelta") && *ev->stmt != '(' ){
			char nme[BUFSIZ],*n=nme, *s= ev->stmt;
			while(*s && *s != '=') *n++ = *s++;
			*n = 0;
			addSourcePair(nme, malvariables[1]);
		} else
		if ( strstr(ev->stmt,"algebra.leftfetchjoin") && *ev->stmt != '(' ){
			char nme[BUFSIZ],*n=nme, *s= ev->stmt;
			while(*s && *s != '=') *n++ = *s++;
			*n = 0;
			addSourcePair(nme, malvariables[malvartop-1]);
		} else
		if ( strstr(ev->stmt,"algebra.subjoin") && *ev->stmt != '(' ){
			char nme[BUFSIZ],*n=nme, *s= ev->stmt;
			while(*s && *s != '=') *n++ = *s++;
			*n = 0;
			addSourcePair(nme, malvariables[malvartop-1]);
		} else {
			char nme[BUFSIZ],*n=nme, *s= ev->stmt;
			if( *s =='(') s++;
			while(*s && *s != '=') *n++ = *s++;
			*n = 0;
			// update the source direction
			for( i=0; i< malvartop;i++)
				addSourcePair(nme,malvariables[i]);
		}
		fprintf(tachojson,"{\n");
		fprintf(tachojson,"\"qid\":\"%s\",\n",currentfunction?currentfunction:"");
		fprintf(tachojson,"\"tag\":%d,\n",ev->tag);
		fprintf(tachojson,"\"pc\":%d,\n",ev->pc);
		fprintf(tachojson,"\"time\": "LLFMT",\n",ev->clkticks);
		fprintf(tachojson,"\"status\": \"start\",\n");
		fprintf(tachojson,"\"estimate\": "LLFMT",\n",ev->ticks);
		fprintf(tachojson,"\"stmt\": \"%s\",\n",ev->stmt);
		fprintf(tachojson,"\"beautystmt\": \"%s\",\n",line);
		// collect all input producing PCs
		fprintf(tachojson,"\"prereq\":[");
		for( i=0; i < malvartop; i++){
			// remove duplicates
			for(j= ev->pc-1; j>=0;j --){
				//if(debug)
					//fprintf(stderr,"locate %s in %s\n",malvariables[i], events[j].stmt);
				if(events[j].stmt && (v = strstr(events[j].stmt, malvariables[i])) && v < strstr(events[j].stmt,":=")){
					snprintf(number,BUFSIZ,"%d",j);
					if( strstr(prereq,number) == 0)
						snprintf(prereq + strlen(prereq), BUFSIZ-1-strlen(prereq), "%s%d",(i?", ":""), j);
					//fprintf(tachojson,"%s%d",(i?", ":""), j);
					break;
				}
			}
		}
		fprintf(tachojson,"%s",prereq);
		fprintf(tachojson,"]\n");
		fprintf(tachojson,"},\n");
		fflush(tachojson);

		clearArguments();
		return;
	}
	if( tachojson == NULL){
		if( debug) fprintf(stderr,"No tachojson available\n");
		return;
	}
	/* end the instruction box */
	if (ev->state == DONE ){
			
		if( ev->tag != currenttag)
			return;	// forget all except one query
		fprintf(tachojson,"{\n");
		fprintf(tachojson,"\"qid\":\"%s\",\n",currentfunction?currentfunction:"");
		fprintf(tachojson,"\"tag\":%d,\n",ev->tag);
		fprintf(tachojson,"\"pc\":%d,\n",ev->pc);
		fprintf(tachojson,"\"time\": "LLFMT",\n",ev->clkticks);
		fprintf(tachojson,"\"status\": \"done\",\n");
		fprintf(tachojson,"\"ticks\": "LLFMT",\n",ev->ticks);
		fprintf(tachojson,"\"stmt\": \"%s\",\n",ev->stmt);
		renderCall(line,BUFSIZ, ev->stmt,1,1);
		fprintf(tachojson,"\"beautystmt\": \"%s\"\n",line);
		fprintf(tachojson,"},\n");
		fflush(tachojson);

		events[ev->pc].state= FINISHED;
		free(ev->stmt);
		//if( duration)
			//progress = (int)(ev->clkticks / (duration/100.0));
		//else
			progress = (int)(pccount++ / (malsize/100.0));
		if( progress > prevprogress ){
			// pick up last unfinished instruction
			for(i= lastpc; i >0; i--)
				if( events[i].state == RUNNING && events[i].stmt)
					break;
			if( progress < prevprogress)
				progress = prevprogress;
			if( ev->clkticks >delay * 1000 && interactive){
				showBar((progress>100.0?(int)100:(int)progress),ev->clkticks,events[i].stmt);
				prevprogress = progress>100.0?100: (int)progress;
			}
		}
		events[ev->pc].actual= ev->ticks;
		clearArguments();
	}
	if (ev->state == DONE && ev->fcn && strncmp(ev->fcn, "function", 8) == 0) {
		if (currentfunction && strcmp(currentfunction, ev->fcn+9) == 0) {
			if( capturing == 0){
				free(currentfunction);
				currentfunction = 0;
			}
			if( ev->clkticks >delay * 1000 && interactive)
				showBar(100,ev->clkticks, 0);
			capturing--;
			if(debug)
				fprintf(stderr, "Leave function %s capture %d\n", currentfunction, capturing);
			resetTachograph();
		} 
	}
}

int
main(int argc, char **argv)
{
	ssize_t  n;
	size_t len;
	char *host = NULL;
	int portnr = 0;
	char *uri = NULL;
	char *user = NULL;
	char *password = NULL;
	char buf[BUFSIZ], *e, *response;
	int i = 0;
	FILE *trace = NULL;
	EventRecord event;

	static struct option long_options[15] = {
		{ "dbname", 1, 0, 'd' },
		{ "user", 1, 0, 'u' },
		{ "port", 1, 0, 'p' },
		{ "password", 1, 0, 'P' },
		{ "host", 1, 0, 'h' },
		{ "help", 0, 0, '?' },
		{ "beat", 1, 0, 'b' },
		{ "interactive", 1, 0, 'i' },
		{ "output", 1, 0, 'o' },
		{ "cache", 1, 0, 'c' },
		{ "wait", 1, 0, 'w' },
		{ "debug", 0, 0, 'D' },
		{ 0, 0, 0, 0 }
	};

	/* parse config file first, command line options override */
	parse_dotmonetdb(&user, &password, NULL, NULL, NULL, NULL);

	while (1) {
		int option_index = 0;
		int c = getopt_long(argc, argv, "d:u:p:P:h:?:b:i:o:c:w:D",
					long_options, &option_index);
		if (c == -1)
			break;
		switch (c) {
		case 'i':
			interactive = atoi(optarg ? optarg : "1") == 1;
			break;
		case 'b':
			beat = atoi(optarg ? optarg : "5000");
			break;
		case 'w':
			delay = atoi(optarg ? optarg : "5000");
			break;
		case 'D':
			debug = 1;
			break;
		case 'd':
			dbname = optarg;
			break;
		case 'u':
			if (user)
				free(user);
			user = strdup(optarg);
			/* force password prompt */
			if (password)
				free(password);
			password = NULL;
			break;
		case 'P':
			if (password)
				free(password);
			password = strdup(optarg);
			break;
		case 'p':
			if (optarg)
				portnr = atoi(optarg);
			break;
		case 'h':
			host = optarg;
			break;
		case 'o':
			basefilename = strdup(optarg);
			if( strstr(basefilename,".trace"))
				*strstr(basefilename,".trace") = 0;
			printf("-- Output directed towards %s\n", basefilename);
			break;
		case 'c': // cache directory
			cache = strdup(optarg);
			break;
		case '?':
			usageTachograph();
			/* a bit of a hack: look at the option that the
			   current `c' is based on and see if we recognize
			   it: if -? or --help, exit with 0, else with -1 */
			exit(strcmp(argv[optind - 1], "-?") == 0 || strcmp(argv[optind - 1], "--help") == 0 ? 0 : -1);
		default:
				usageTachograph();
			exit(-1);
		}
	}

	if(dbname == NULL){
		usageTachograph();
		exit(-1);
	}

	if(debug)
		printf("tachograph -d %s -c %s -o %s\n",dbname,cache,basefilename);

	if (dbname != NULL && strncmp(dbname, "mapi:monetdb://", 15) == 0) {
		uri = dbname;
		dbname = NULL;
	}

#ifdef SIGPIPE
	signal(SIGPIPE, stopListening);
#endif
#ifdef SIGHUP
	signal(SIGHUP, stopListening);
#endif
#ifdef SIGQUIT
	signal(SIGQUIT, stopListening);
#endif
	signal(SIGINT, stopListening);
	signal(SIGTERM, stopListening);
	close(0);

	if (user == NULL)
		user = simple_prompt("user", BUFSIZ, 1, prompt_getlogin());
	if (password == NULL)
		password = simple_prompt("password", BUFSIZ, 0, NULL);

	/* our hostname, how remote servers have to contact us */
	gethostname(hostname, sizeof(hostname));

	/* set up the profiler */
	if (uri)
		dbh = mapi_mapiuri(uri, user, password, "mal");
	else
		dbh = mapi_mapi(host, portnr, user, password, "mal", dbname);
	if (dbh == NULL || mapi_error(dbh))
		die(dbh, hdl);
	mapi_reconnect(dbh);
	if (mapi_error(dbh))
		die(dbh, hdl);
	host = strdup(mapi_get_host(dbh));
	if(debug)
		fprintf(stderr,"-- connection with server %s\n", uri ? uri : host);

	for (portnr = 50010; portnr < 62010; portnr++) 
		if ((conn = udp_rastream(hostname, portnr, "profileStream")) != NULL)
			break;
	
	if ( conn == NULL) {
		fprintf(stderr, "!! opening stream failed: no free ports available\n");
		fflush(stderr);
		goto stop_disconnect;
	}

	printf("-- opened UDP profile stream %s:%d for %s\n", hostname, portnr, host);

	snprintf(buf, BUFSIZ, " port := profiler.openStream(\"%s\", %d);", hostname, portnr);
	if( debug)
		fprintf(stderr,"--%s\n",buf);
	doQ(buf);

	snprintf(buf,BUFSIZ-1,"profiler.stethoscope(%d);",beat);
	if( debug)
		fprintf(stderr,"-- %s\n",buf);
	doQ(buf);
	if( cache){
#ifdef NATIVE_WIN32
		_mkdir(cache);
		snprintf(buf,BUFSIZ,"%s\\%s_%s.trace",cache,basefilename,dbname);
#else
		mkdir(cache,0755);
		snprintf(buf,BUFSIZ,"%s/%s_%s.trace",cache,basefilename,dbname);
#endif
	} else
		snprintf(buf,BUFSIZ,"%s_%s.trace",basefilename,dbname);
	// keep a trace of the events received
	trace = fopen(buf,"w");
	if( trace == NULL)
		fprintf(stderr,"Could not create trace file\n");

	len = 0;
	while ((n = mnstr_read(conn, buf + len, 1, BUFSIZ - len)) > 0) {
		buf[len + n] = 0;
		response = buf;
		while ((e = strchr(response, '\n')) != NULL) {
			*e = 0;
			if(debug)
				printf("%s\n", response);
			i= eventparser(response, &event);
			update(&event);
			if (debug  )
				fprintf(stderr, "PARSE %d:%s\n", i, response);
			if( trace && i >=0 && capturing) 
				fprintf(trace,"%s\n",response);
			if( tachotrace && i >=0 && capturing) 
				fprintf(tachotrace,"%s\n",response);
			response = e + 1;
		}
		/* handle last line in buffer */
		if (*response) {
			if (debug)
				printf("LASTLINE:%s", response);
			len = strlen(response);
			strncpy(buf, response, len + 1);
		} else
			len = 0;
	}

	doQ("profiler.stop();");
stop_disconnect:
	if(dbh)
		mapi_disconnect(dbh);
	printf("-- connection with server %s closed\n", uri ? uri : host);
	return 0;
}
