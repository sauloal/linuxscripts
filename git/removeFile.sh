#!/bin/bash
#deletes all the history of a given file
#move file away, commit, push and clean

FOLDER=$1
FILE=$2
#http://help.github.com/removing-sensitive-data/

bash commit.sh $FOLDER
bash clean.sh $FOLDER


SHORTFILE=`basename $FILE`
cp $FOLDER/$FILE ./$SHORTFILE.bak

cd $FOLDER
	#git stash
	CMD="git filter-branch -f --index-filter 'git rm --cached --ignore-unmatch $FILE' HEAD"
	echo $CMD
	eval $CMD

	git commit -a --status -m "deleting $FILE"
	git push origin master --force
	git reflog expire --expire=now --all
	git gc --prune=now
	git gc --aggressive --prune=now
cd ..

echo "TO RESTORE:"
echo "cp ./$SHORTFILE.bak $FOLDER/$FILE"

