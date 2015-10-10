set ROOTDIR=%CD%
set LIBDIR=%1
set CURLDIR=%2

echo "Amalgamating target dir: %LIBDIR% curldir: %CURLDIR%"

copy %CURLDIR%\*.lib %LIBDIR:/=\%
cd %LIBDIR%
rmdir /s /q "tmp\"
mkdir tmp
del gameplay-deps.lib
move *.lib tmp

LIB.EXE /OUT:gameplay-deps.lib tmp\*

cd %ROOTDIR%
