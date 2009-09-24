
[Setup]
AppName=MonetDB
AppVerName=MonetDB 4.32.2
DefaultDirName={pf}\MonetDB
DefaultGroupName=MonetDB
UninstallDisplayIcon={app}\bin\Mserver.exe
Compression=lzma
SolidCompression=yes
SetupIconFile=

[Files]
Source: "bin\libbat-0.dll"; DestDir: "{app}\bin"; 
Source: "bin\libMapi-0.dll"; DestDir: "{app}\bin"; 
Source: "bin\libmonet-0.dll"; DestDir: "{app}\bin";
Source: "bin\libmutils-0.dll"; DestDir: "{app}\bin";
Source: "bin\libstream-0.dll"; DestDir: "{app}\bin";
Source: "bin\mclient"; DestDir: "{app}\bin";
Source: "bin\mclient.exe"; DestDir: "{app}\bin";
Source: "bin\mclient.py"; DestDir: "{app}\bin";
Source: "bin\mclient.py.bat"; DestDir: "{app}\bin";
Source: "bin\Mapprove.py"; DestDir: "{app}\bin";
Source: "bin\Mapprove.py.bat"; DestDir: "{app}\bin";
Source: "bin\Mdiff.exe"; DestDir: "{app}\bin";
Source: "bin\Mfilter.py"; DestDir: "{app}\bin";
Source: "bin\Mfilter.pyc"; DestDir: "{app}\bin";
Source: "bin\MkillUsers"; DestDir: "{app}\bin";
Source: "bin\Mlog"; DestDir: "{app}\bin";
Source: "bin\Mlog.bat"; DestDir: "{app}\bin";
Source: "bin\monetdb-config"; DestDir: "{app}\bin";
Source: "bin\monetdb-config.bat"; DestDir: "{app}\bin";
Source: "bin\Mserver"; DestDir: "{app}\bin"; 
Source: "bin\Mserver.exe"; DestDir: "{app}\bin"; 
Source: "bin\Mtest.py"; DestDir: "{app}\bin"; 
Source: "bin\Mtest.py.bat"; DestDir: "{app}\bin"; 

[Messages]
AboutSetupNote=MonetDB home page:%nhttp://www.monetdb.com/

[Icons]
Name: "{group}\MonetDB"; Filename: "{app}\bin\Mserver.exe"
