module namespace admin = 'http://monetdb.cwi.nl/XQuery/admin/';

(: ADMIN MODULE, by Peter Boncz (boncz@cwi.nl)
 :
 : - makes administrative functionality available over SOAP 
 : - standard part of the MonetDB/XQuery distribution 
 : - can only be called from IPs listed in xrpc_admin (MonetDB.conf option)
 :)

declare namespace pf = 'http://www.pathfinder-xquery.org/';

(: =================== document management =================== :)

declare function admin:collections() 
{ pf:collections-unsafe() };

declare function admin:documents()
{ pf:documents-unsafe() };

declare function admin:documents($collection as xs:string) 
{ pf:documents-unsafe($collection) };

declare document management function admin:add-doc($uri as xs:string, $document as xs:string, $collection as xs:string, $percentage as xs:integer) 
{ pf:add-doc($uri, $document, $collection, $percentage) };

declare document management function admin:del-doc($document as xs:string) 
{ pf:del-doc($document) };

declare document management function admin:del-col($collection as xs:string) 
{ let $docs := pf:documents-unsafe($collection) 
  return if (count($docs) = 0) 
    then error("collection not found")
    else for $document in $docs 
         return pf:del-doc($document) 
};


(: =================== backup & restore =================== :)

declare updating function admin:backup-col($collection as xs:string, $bakname as xs:string)
{
  let $path  := concat('backup/', $bakname, '/', $collection, '/')
  let $index := 
   element documents {
     for $document at $pos in pf:documents($collection)
     let $uri := concat($path, string(10000 + (($pos div 10000)) cast as xs:integer), '/',  string($pos) , '.xml')
     return (text { "&#10;  " }, element document { attribute uri {$uri}, $document/text() }),
     text { "&#10;" } }
  return 
   (put($index, concat($path,'documents.xml')),
    for $document in $index/document
    return put(exactly-one(doc(string($document))), exactly-one($document/@uri)))
};

declare updating function admin:backup($bakname as xs:string)
{
  let $path  := concat('backup/', $bakname, '/')
  let $index := 
    element collections {
      for $collection in pf:collections() 
      return (text { "&#10;  " }, element collection { attribute updatable {$collection/@updatable}, $collection/text() }),
      text { "&#10;" } }
  return 
    (put($index, concat($path,'collections.xml')),
     for $collection in pf:collections() 
     return admin:backup-col($collection, $bakname))
};


declare document management function admin:restore-col($collection as xs:string, $bakname as xs:string, $percentage as xs:integer)
{
  for $document in doc(concat('backup/', $bakname, '/', $collection, '/documents.xml'))//document
  return pf:add-doc(exactly-one($document/@uri), exactly-one($document/text()), $collection, $percentage)
};

declare document management function 
admin:restore($bakname as xs:string, $percentage as xs:integer)
{
  for $collection in doc(concat('backup/', $bakname, '/collections.xml'))//collection
  let $perc := if ($collection/@updatable = 'true') then $percentage else 0
  return admin:restore-col(exactly-one($collection/text()), $bakname, $perc) 
};



(: =================== server management =================== :)

declare function admin:db-stats() 
{ pf:mil('lock_set(pf_short); var ret := bat(str,str); var tot := 0LL; colname_runtime@batloop() tot :+= sum([batsize]($t)); ret.insert("xquery_index_curMB", str(tot/1048576LL)); tot := doc_timestamp.select(timestamp_nil,timestamp_nil).reverse(); ret.insert("xquery_cache_curdocs", str(count(tot))); tot := tot.join(doc_collection).tunique().reverse().join(collection_size).sum(); ret.insert("xquery_cache_curMB", str(tot/1048576LL)); ret.insert("xquery_log_curMB", str((logger_changes(pf_logger) - logger_base)/131072)); ret.insert("gdk_vm_cursize", str(vm_cursize())); ret.insert("gdk_mem_cursize", str(mem_cursize())); lock_unset(pf_short); return ret;') };

declare function admin:db-env() 
{ pf:mil('var dels := new(void, str, 20).append("exec_prefix").append("prefix").append("gdk_debug").append("gdk_embedded").append("gdk_vm_minsize").append("mapi_debug").append("mapi_noheaders").append("monet_daemon").append("monet_mod_path").append("monet_pid").append("monet_prompt").append("monet_welcome").append("sql_debug").append("sql_logdir").reverse(); return monet_environment.kdiff(dels).access(BAT_WRITE).insert("gdk_mem_maxsize", str(mem_maxsize())).sort();') };

(: =================== HTTP =================== :)

declare function admin:GET($uri as xs:string) 
{ doc($uri) };

declare updating function admin:PUT($uri as xs:string, $doc as element()) 
{ 
  if (substring($uri, 1,4) = 'tmp/') 
  then put($doc, $uri) 
  else error('PUT: only relative URIs starting with tmp/ allowed') 
};

declare document management function admin:DELETE($uri as xs:string) 
{ 
  if (substring($uri, 1,4) = 'tmp/') 
  then pf:del-doc($uri) 
  else error('DELETE: only relative URIs starting with tmp/ allowed') 
};
