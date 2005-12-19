import os, time

def main():
    srvcmd = '%s --dbinit "module(sql_server,mapi,monettime); mapi_start();"' % os.getenv('MSERVER')
    srv = os.popen(srvcmd, 'w')
    time.sleep(10)                      # give server time to start
    cltcmd = os.getenv('MAPI_CLIENT')
    clt = os.popen(cltcmd, 'w')
    clt.close()
    srv.close()

main()
