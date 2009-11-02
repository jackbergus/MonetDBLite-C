@echo on
@prompt # $t $g  

@set NAME=%1
@set PRELUDE=%2 %3

@cd %TSTTRGDIR%

@copy /y "%TSTSRCDIR%\..\README"      README      > nul
@copy /y "%TSTSRCDIR%\..\awkscript"   awkscript   > nul
@copy /y "%TSTSRCDIR%\..\column"      column      > nul
@copy /y "%TSTSRCDIR%\..\format"      format      > nul
@copy /y "%TSTSRCDIR%\..\gcol"        gcol        > nul
@copy /y "%TSTSRCDIR%\..\summary"     summary     > nul
@copy /y "%TSTSRCDIR%\..\test100k"    test100k    > nul
@copy /y "%TSTSRCDIR%\..\init.mil"    init.mil    > nul
@copy /y "%TSTSRCDIR%\..\void.mil"    void.mil    > nul
@copy /y "%TSTSRCDIR%\..\tstvoid.mil" tstvoid.mil > nul
@copy /y "%TSTSRCDIR%\..\load.mil"    load.mil    > nul

@set TSTDB=%TSTDB%_%NAME%

@if exist "%GDK_DBFARM%\%TSTDB%" rmdir /s/q "%GDK_DBFARM%\%TSTDB%"

mkdir "%GDK_DBFARM%\%TSTDB%"
@rem  %MLOAD% test100k -db %TSTDB% -oid 30000000 -s 100000 -f format
%MSERVER% "--dbname=%TSTDB%"         < load.mil
%MSERVER% "--dbname=%TSTDB%"         < init.mil
%MSERVER% "--dbname=%TSTDB%"         < void.mil
%MSERVER% "--dbname=%TSTDB%"         < %NAME%.mil
@rem  | tee output
@rem  PATH=/bin:$PATH ; export PATH
@rem  sh summary

@rem rmdir /s/q "%GDK_DBFARM%\%TSTDB%"

