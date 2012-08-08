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
 * @a M.L. Kersten
 * @+ Name Space Management.
 * Significant speed improvement at type resolution and during the
 * optimization phases can be gained when each module or function identifier is
 * replaced by a fixed length internal identifier. This translation is
 * done once during parsing.
 * Variables are always stored local to the MAL block in which they
 * are used.
 *
 * The number of module and function names is expected to be limited.
 * Therefore, the namespace manager is organized as a shared table. The alternative
 * is a namespace per client. However, this would force
 * passing around the client identity or an expensive operation to deduce
 * this from the process id. The price paid is that updates to the namespace
 * should be protected against concurrent access.
 * The current version is protected with locks, which by itself may cause quite
 * some overhead.
 *
 * The space can, however, also become polluted with identifiers generated on the fly.
 * Compilers are adviced to be conservative in their naming, or explicitly manage
 * the name space by deletion of non-used names once in a while.
 */
/*
 * @+ Code bodies
 * The Namespace block is organized using a simple hashstructure over the first
 * character. Better structures can be introduced when searching becomes
 * too expensive. An alternative would be to use a BAT to handle the collection.
 */
#include "monetdb_config.h"
#include "mal_type.h"
#include "mal_namespace.h"
#include "mal_exception.h"
#define MAXIDENTIFIERS 2048

typedef struct NAMESPACE{
	int  size;  /* amount of space available */
	int  nmetop;
	str  *nme;
	int  *link;
	int  *hit;
	size_t	 *length;
	int	 totalhit;
} Namespace;

static Namespace namespace;
#ifdef _BACKUP_
/* code to aid hunting for illegal frees on the namespace */
static Namespace backup;
#endif

static void expandNamespace(int incr){
	str *nme;
	size_t *length;
	int *link, *hit, newsize;

	assert( incr > 0 );

	newsize= namespace.size+incr;
	nme= (str *) GDKmalloc(sizeof(str *) * newsize);
	assert(nme != NULL); /* we cannot continue */
	link= (int *) GDKmalloc(sizeof(int) * newsize);
	assert(link != NULL); /* we cannot continue */
	hit = (int *) GDKmalloc(sizeof(int) * newsize);
	assert(hit != NULL); /* we cannot continue */
	length = (size_t *) GDKmalloc(sizeof(size_t) * newsize);
	assert(length != NULL); /* we cannot continue */

	memcpy(nme, namespace.nme, sizeof(str *) * namespace.nmetop);
	memcpy(link, namespace.link, sizeof(int) * namespace.nmetop);
	memcpy(hit, namespace.hit, sizeof(int) * namespace.nmetop);
	memcpy(length, namespace.length, sizeof(size_t) * namespace.nmetop);

	namespace.size += incr;
	namespace.totalhit= 0;
	GDKfree(namespace.nme); namespace.nme= nme;
	GDKfree(namespace.link); namespace.link= link;
	GDKfree(namespace.hit); namespace.hit= hit;
	GDKfree(namespace.length); namespace.length= length;

#ifdef _BACKUP_
	nme= (str *) GDKmalloc(sizeof(str *) * (backup.nmetop+incr));
	link= (int *) GDKmalloc(sizeof(int) * (backup.nmetop+incr));
	hit = (int *) GDKmalloc(sizeof(int) * (backup.nmetop+incr));
	length = (size)t *) GDKmalloc(sizeof(size_t) * (backup.nmetop+incr));
	memcpy(nme, backup.nme, sizeof(str *) * backup.nmetop);
	memcpy(link, backup.link, sizeof(int) * backup.nmetop);
	memcpy(hit, backup.hit, sizeof(int) * backup.nmetop);
	memcpy(length, backup.hit, sizeof(size_t) * backup.nmetop);

	backup.size += incr;
	backup.totalhit= 0;
	GDKfree(backup.nme); backup.nme= nme;
	GDKfree(backup.link); backup.link= link;
	GDKfree(backup.hit); backup.hit= hit;
	GDKfree(backup.length); backup.length= length;
#endif

}
void initNamespace(void) {
	namespace.nme= (str *) GDKzalloc(sizeof(str *) * MAXIDENTIFIERS);
	namespace.link= (int *) GDKzalloc(sizeof(int) * MAXIDENTIFIERS);
	namespace.hit= (int *) GDKzalloc(sizeof(int) * MAXIDENTIFIERS);
	namespace.length= (size_t *) GDKzalloc(sizeof(size_t) * MAXIDENTIFIERS);
	if ( namespace.nme == NULL ||
		 namespace.link == NULL ||
		 namespace.hit == NULL ||
		 namespace.length == NULL) {
		/* absolute an error we can not recover from */
		showException(GDKout, MAL,"initNamespace",MAL_MALLOC_FAIL);
		mal_exit();
	}
	namespace.size = MAXIDENTIFIERS;
	namespace.nmetop= 256; /* hash overflow */

#ifdef _BACKUP_
	backup.nme= (str *) GDKzalloc(sizeof(str *) * MAXIDENTIFIERS);
	backup.link= (int *) GDKzalloc(sizeof(int) * MAXIDENTIFIERS);
	backup.hit= (int *) GDKzalloc(sizeof(int) * MAXIDENTIFIERS);
	backup.length= (size_t *) GDKzalloc(sizeof(size_t) * MAXIDENTIFIERS);
	if ( backup.nme == NULL ||
		 backup.link == NULL ||
		 backup.hit == NULL ||
		 backup.length == NULL) {
		/* absolute an error we can not recover from */
		showException(GDKout, MAL,"initNamespace",MAL_MALLOC_FAIL);
		mal_exit();
	}
	backup.size = MAXIDENTIFIERS;
	backup.nmetop= 256; /* hash overflow */
#endif
}
void finishNamespace(void) {
	int i;
	for(i=0;i<namespace.nmetop; i++) {
		if( namespace.nme[i])
			GDKfree(namespace.nme[i]);
		namespace.nme[i]= 0;
	}
	GDKfree(namespace.nme); namespace.nme= 0;
	GDKfree(namespace.link); namespace.link= 0;
	GDKfree(namespace.hit); namespace.hit= 0;
	GDKfree(namespace.length); namespace.length= 0;
#ifdef _BACKUP_
	GDKfree(backup.nme);	backup.nme=0;
	GDKfree(backup.link);	backup.link=0;
	GDKfree(backup.hit);	backup.hit=0;
	GDKfree(backup.length);	backup.length=0;
#endif
}

#ifdef _BACKUP_
void chkName(int l){
	int i;
	if( namespace.nme[l] && strcmp(namespace.nme[l],backup.nme[l])!=0){
		printf("error in namespace %d\n",l);
		printf("backup %s\n",backup.nme[l]);
		for( i=0; i< strlen(backup.nme[l]); i++)
		printf("[%d] %d '%c'\n",i, namespace.nme[l][i], namespace.nme[l][i]);

	}
}
#endif
/*
 * @-
 * Before a name is being stored we should check for its occurrence first.
 * The administration is initialized incrementally.
 * Beware, the routine getName is not thread safe under updates
 * of the namespace itself.
 */
str getName(str nme, size_t len)
{
	size_t l;
	if(len == 0 || nme== NULL || *nme==0) return 0;

	for(l= nme[0]; l && namespace.nme[l]; l= namespace.link[l]){
#ifdef _BACKUP_
		chkName(l);
#endif
		if (namespace.length[l] == len  &&
			strncmp(nme,namespace.nme[l],len)==0) {
	        namespace.hit[l]++;
			namespace.totalhit++;
			return namespace.nme[l];
	    }
	}
	return 0;
}
/*
 * @-
 * Name deletion from the namespace is tricky, because there may
 * be multiple threads active on the structure. Moreover, the
 * symbol may be picked up by a concurrent thread and stored
 * somewhere.
 * To avoid all these problems, the namespace should become
 * private to each Client, but this would mean expensive look ups
 * deep into the kernel to access the context.
 */
void delName(str nme, size_t len){
	str n;
	n= getName(nme,len);
	if( nme[0]==0 || n == 0) return ;

	MT_lock_set(&mal_contextLock, "putName");
	/*Namespace garbage collection not available yet */
	MT_lock_unset(&mal_contextLock, "putName");
}
str putName(str nme, size_t len)
{
	size_t l,top;
	char buf[MAXIDENTLEN];

	if( nme == NULL)
		return NULL;
	for(l= nme[0]; l && namespace.nme[l]; l= namespace.link[l]){
#ifdef _BACKUP_
		chkName(l);
#endif
	    if( namespace.length[l] == len  &&
			strncmp(nme,namespace.nme[l],len) == 0 ) {
	        namespace.hit[l]++;
			namespace.totalhit++;
			/* aggressive test for reorganization needs */
			/* this is a potential concurreny problem */
/*	Move it to a separate routine, avoid excessive locking and
	serialization
			if( k && 2*namespace.hit[k] < namespace.hit[l]){
				str s;
				int h,i;
				s= namespace.nme[l]; namespace.nme[l]= namespace.nme[k];
				namespace.nme[k]=s;
				h= namespace.hit[l]; namespace.hit[l]=namespace.hit[k];
				namespace.hit[k]= h;
				i= namespace.length[l]; namespace.length[l]=namespace.length[k];
				namespace.length[k]= i;

#ifdef _BACKUP_
				s= backup.nme[l]; backup.nme[l]= backup.nme[k];
				backup.nme[k]=s;
				i= backup.hit[l]; backup.hit[l]=backup.hit[k];
				backup.hit[k]= i;
				i= backup.length[l]; backup.length[l]=backup.length[k];
				backup.length[k]= i;
#endif
				l=k;
			}
*/
			return namespace.nme[l];
	    }
	}

	/* protect this, as it will be updated by multiple threads */
	MT_lock_set(&mal_contextLock, "putName");
	if(len>=MAXIDENTLEN)
		len = MAXIDENTLEN - 1;
	memcpy(buf, nme, len);
	buf[len]=0;

	if( namespace.nmetop+1== namespace.size)
	    expandNamespace(MAXIDENTIFIERS);
	l= nme[0];
	top= namespace.nme[l]== 0? (int)l: namespace.nmetop;
	namespace.nme[top]= GDKstrdup(buf);
	namespace.link[top]= namespace.link[l];
	if ((int)top == namespace.nmetop)
		namespace.link[l] = (int)top;
	namespace.hit[top]= 0;
	namespace.length[top]= len;
	namespace.nmetop++;

#ifdef _BACKUP_
	top= backup.nme[l]== 0? l: backup.nmetop;
	backup.nme[top]= GDKstrdup(buf);
	backup.link[top]= backup.link[l];
	if( top == backup.nmetop)
		backup.link[l]= top;
	backup.nmetop++;
#endif
	MT_lock_unset(&mal_contextLock, "putName");
	if ( len)
		return putName(nme, len);	/* just to be sure */
	return NULL;
}
/*
 * @-
 * The namespace may become a bottleneck when the chain of identifiers grows.
 * This issue can be tackled from two angles. Either we change the hash function
 * using multiple characters of the identifier or we sort the identifiers list
 * using the actual hits reported so far. The field hit keeps track of this
 * crucial information. The choice on the way to move forward is postponed.
 *
 * The re-organization scheme can be triggered by the calls made
 * to the namespace.
 */
void dumpNamespaceStatistics(stream *f, int details)
{
	int i,l,cnt,hits,steps;

	mnstr_printf(f,"Namespace statistics\n");
	mnstr_printf(f,"nmetop = %d size= %d\n",
	    namespace.nmetop, namespace.size);
	for(i=0;i<256; i++)
	if(namespace.nme[i]){
	    hits= steps= cnt =0;
	    mnstr_printf(f,"list %d ",i);
	    for(l= i; l && namespace.nme[l]; l= namespace.link[l]){
	        cnt++;
	        if(details) {
	            mnstr_printf(f,"(%s %d) ",
	            namespace.nme[l], namespace.hit[l]);
	            if( i+1 % 5 == 0) mnstr_printf(f,"\n");
				hits+= namespace.hit[l];
				steps += namespace.hit[l]*cnt;
	        }
	    }
	    if(cnt)  mnstr_printf(f," has %d elements, %d hits, %d steps",cnt,hits,steps/(hits+1));
		mnstr_printf(f,"\n");
	}
}
