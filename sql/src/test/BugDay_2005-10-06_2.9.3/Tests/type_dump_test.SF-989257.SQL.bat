@echo off

set JAR=""
if exist "%SQL_BUILD%\src\jdbc\MonetDB_JDBC.jar"		set JAR=%SQL_BUILD%\src\jdbc\MonetDB_JDBC.jar
if exist "%TSTBLDBASE%\src\jdbc\MonetDB_JDBC.jar"		set JAR=%TSTBLDBASE%\src\jdbc\MonetDB_JDBC.jar
if exist "%SQL_PREFIX%\share\MonetDB\lib\MonetDB_JDBC.jar"	set JAR=%SQL_PREFIX%\share\MonetDB\lib\MonetDB_JDBC.jar
if exist "%MONETDB_PREFIX%\share\MonetDB\lib\MonetDB_JDBC.jar"	set JAR=%MONETDB_PREFIX%\share\MonetDB\lib\MonetDB_JDBC.jar
if JAR == ""							set JAR=%TSTTRGBASE%\share\MonetDB\lib\MonetDB_JDBC.jar

echo user=monetdb>	.monetdb
echo password=monetdb>>	.monetdb

set LANG=en_US.UTF-8

call Mlog.bat -x java -jar "%JAR%" -h %HOST% -p %MAPIPORT% -f "%RELSRCDIR%\type_dump_test.SF-989257-src.sql"

del .monetdb
