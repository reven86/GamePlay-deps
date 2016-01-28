set ROOTDIR=%CD%
set LIBDIR=%1

echo "Amalgamating target dir: %LIBDIR%"

cd %LIBDIR%
rmdir /s /q "tmp\"
mkdir tmp
del gameplay-deps.lib
move *.lib tmp

LIB.EXE /OUT:gameplay-deps.lib tmp\*

cd %ROOTDIR%
