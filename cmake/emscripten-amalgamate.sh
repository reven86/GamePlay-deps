#!/bin/bash

if [ $# -ne 2 ];
then
    echo "Usage: emscripten-amalgamate.sh <ar command> <target directory>"
    exit 1
fi

CWD=`pwd`
AR="$1"
TARGET="$2"

if [ ! -e $AR ];
then
    echo "No such file: $AR"
    exit 1
fi

if [ ! -d $TARGET ];
then
    echo "No such target directory: $AR"
    exit 1
fi

echo "Using ar : $AR"
echo "Amalgamating target static libs $TARGET"

cd $TARGET
#mkdir tmp
rm -f libgameplay-deps.a
#mv *.a ./tmp

#echo "create libgameplay-deps.a"
#for file in ./tmp/* ; do
#    if [ -e "$file" ];
#    then
#	$AR r libgameplay-deps.a $file
#        echo "addlib $file"
#    fi
#done
#echo "end"

# Clean up
#emscripten does not support amalgamated archives so leave reps as they are
#rm -rf ./tmp

cd $CWD
