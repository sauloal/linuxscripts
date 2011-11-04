#!/bin/bash
#deletes all the history of a given file
#move file away, commit, push and clean

FOLDER=$1
FILE=$2
#http://help.github.com/removing-sensitive-data/

if [[ ! -d "$FOLDER" ]]; then
    echo "NO FOLDER DEFINED"
    exit 1
fi

if [[ -z "$FILE" ]]; then
    echo "NO FILE DEFINED"
    exit 1
fi

if [[ ! -f "$FOLDER/$FILE" ]]; then
    echo "NO SUCH FILE '$FOLDER/$FILE'"
    echo "SHOULD I TRY ANYWAYS? (y/n) "
    read should

    if [[ "$should" != "y" ]]; then
        echo "EXITING THEN"
        exit 1
    fi
fi


bash commit.sh $FOLDER
#bash clean.sh $FOLDER


SHORTFILE=`basename $FILE`
if [[ -f "$FILE" ]]; then
	cp $FOLDER/$FILE ./$SHORTFILE.bak
fi

CURRPWD=`pwd`
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
cd $CURRPWD

echo "TO RESTORE:"
echo "cp ./$SHORTFILE.bak $FOLDER/$FILE"

