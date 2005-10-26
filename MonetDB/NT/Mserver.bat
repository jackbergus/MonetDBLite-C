@echo off

setlocal

rem figure out the folder name
set MONETDB=%~dp0

rem remove the final backslash from the path
set MONETDB=%MONETDB:~0,-1%

rem extend the search path with our EXE and DLL folders
rem we depend on pthreadVCE.dll having been copied to the lib folder
set PATH=%MONETDB%\bin;%MONETDB%\lib;%MONETDB%\lib\bin;%MONETDB%\lib\MonetDB;%MONETDB%\lib\MonetDB\bin;%PATH%

rem possibly move the database from a previous installation to our
rem currently preferred location, and prepare the arguments to Mserver
rem to tell it where that location is

set MONETDBDIR=
set MONETDBFARM=
set SQLLOGDIR=
rem use the Application Data folder for our database

rem if installed for just the current user, the file
rem %APPDATA%\MonetDB\VERSION was created by the installer, so set
rem MONETDBDIR accordingly.
rem if ALLUSERSPROFILE and APPDATA variables don't exist, forget about
rem this whole exercise and use the default (i.e. %MONETDB\var\MonetDB).

if "%APPDATA%" == "" goto skip

set MONETDBDIR=%APPDATA%\MonetDB

set MONETDBFARM="--dbfarm=%MONETDBDIR%\dbfarm"
set SQLLOGDIR=--set "sql_logdir=%MONETDBDIR%\log"

if exist "%MONETDBDIR%" goto skip

rem if the database exists by the ancient name, move it
if not exist "%MONETDB%\var\MonetDB" goto skip1
move "%MONETDB%\var\MonetDB" "%MONETDBDIR%"
rmdir "%MONETDB%\var"
goto skip

:skip1

rem if the database exists by the old name, move it
if not exist "%ALLUSERSPROFILE%\Application Data\MonetDB" goto skip
move "%ALLUSERSPROFILE%\Application Data\MonetDB" "%MONETDBDIR%"

:skip

rem start the real server
"%MONETDB%\bin\Mserver.exe" --set "prefix=%MONETDB%" --set "exec_prefix=%MONETDB%" %MONETDBFARM% %SQLLOGDIR% %*

endlocal
