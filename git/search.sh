#!/bin/bash
#grep project

FOLDER=$1
TERM=$2
OPTIONS=$3
echo "TERMS '$TERM' OPTIONS '$OPTIONS'"


if [ ! -n "$FOLDER" ];
then
	echo "NO FOLDER DEFINED $FOLDER"
	exit 1
fi

if [ ! -d "$FOLDER" ];
then
	echo "FOLDER \"$FOLDER\" DOES NOT EXISTS"	
	exit 2
fi

echo FOLDER BEFORE $FOLDER
FOLDER=${FOLDER%/*}
echo FOLDER AFTER  $FOLDER

cd $FOLDER
	CMD="git grep $OPTIONS '$TERM'"
	echo $CMD
	eval $CMD
cd ..
