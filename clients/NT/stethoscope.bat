@echo off
rem figure out the folder name
set MONETDB=%~dp0

rem remove the final backslash from the path
set MONETDB=%MONETDB:~0,-1%

rem extend the search path with our EXE and DLL folders
rem we depend on pthreadVCE.dll having been copied to the lib folder
set PATH=%MONETDB%\bin;%MONETDB%\lib;%MONETDB%\lib\bin;%PATH%

rem start the real client
"%MONETDB%\bin\stethoscope.exe" %1 %2 %3 %4 %5 %6 %7 %8

if ERRORLEVEL 1 pause
