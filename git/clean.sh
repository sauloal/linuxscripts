#!/bin/bash
# cleans all trash left behind

FOLDER=$1

echo FOLDER BEFORE $FOLDER
FOLDER=${FOLDER%/*}
echo FOLDER AFTER  $FOLDER


cd $FOLDER
git reflog expire --expire=now --all
git gc --prune=now
git gc --aggressive --prune=now
cd ..

bash ./commit.sh $FOLDER

