#!/bin/bash
FOLDER=$1

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
git pull git@github.com:sauloal/$FOLDER.git master
cd ..

