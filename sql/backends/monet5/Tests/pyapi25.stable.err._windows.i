stderr of test 'pyapi25` in directory 'sql/backends/monet5` itself:


# 12:40:00 >  
# 12:40:00 >  "mserver5" "--debug=10" "--set" "gdk_nr_threads=0" "--set" "mapi_open=true" "--set" "mapi_port=30737" "--set" "mapi_usock=/var/tmp/mtest-21450/.s.monetdb.30737" "--set" "monet_prompt=" "--forcemito" "--set" "mal_listing=2" "--dbpath=/home/mytherin/opt/var/MonetDB/mTests_sql_backends_monet5" "--set" "mal_listing=0" "--set" "embedded_r=true" "--set" "embedded_py=true"
# 12:40:00 >  

# builtin opt 	gdk_dbpath = /home/mytherin/opt/var/monetdb5/dbfarm/demo
# builtin opt 	gdk_debug = 0
# builtin opt 	gdk_vmtrim = no
# builtin opt 	monet_prompt = >
# builtin opt 	monet_daemon = no
# builtin opt 	mapi_port = 50000
# builtin opt 	mapi_open = false
# builtin opt 	mapi_autosense = false
# builtin opt 	sql_optimizer = default_pipe
# builtin opt 	sql_debug = 0
# cmdline opt 	gdk_nr_threads = 0
# cmdline opt 	mapi_open = true
# cmdline opt 	mapi_port = 30737
# cmdline opt 	mapi_usock = /var/tmp/mtest-21450/.s.monetdb.30737
# cmdline opt 	monet_prompt = 
# cmdline opt 	mal_listing = 2
# cmdline opt 	gdk_dbpath = /home/mytherin/opt/var/MonetDB/mTests_sql_backends_monet5
# cmdline opt 	mal_listing = 0
# cmdline opt 	embedded_r = true
# cmdline opt 	embedded_py = true
# cmdline opt 	gdk_debug = 536870922

# 12:40:00 >  
# 12:40:00 >  "mclient" "-lsql" "-ftest" "-Eutf-8" "-i" "-e" "--host=/var/tmp/mtest-21450" "--port=30737"
# 12:40:00 >  

MAPI  = (monetdb) /var/tmp/mtest-14818/.s.monetdb.37353
QUERY = SELECT * FROM pyapi25errortable();
ERROR = !SELECT: no such table 'hopefullynonexistanttable'
        !Python exception
        !
        !  1. def pyfun(_columns,_column_types,_conn):
        !> 2.   return _conn.execute('SELECT * FROM HOPEFULLYNONEXISTANTTABLE;')
        !  3.   return 1
        !  4. 
        !SQL Query Failed: ParseException:SQLparser:42S02!SELECT: no such table 'hopefullynonexistanttable'

# 12:40:01 >  
# 12:40:01 >  "Done."
# 12:40:01 >  

