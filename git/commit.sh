#!/bin/bash
# if there are changes
#  update serial
#  commit
#  pull
#  push

FOLDER=$1
MESSAGE=$2
echo $MESSAGE

FORCE=0
DATE=`date --rfc-3339='seconds'`
SECONDS=`date +%s`

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

MESSAGE="$DATE :: $MESSAGE"

echo FOLDER BEFORE $FOLDER
FOLDER=${FOLDER%/*}
echo FOLDER AFTER  $FOLDER
CURRPWD=`pwd`

	cd $FOLDER
	STATUS=`git status -s`
	if [ -z "$STATUS" ]; then
		echo "NO CHANGE. DOING NOTHING"
		if [ "$FORCE" -eq 0 ]; then
			exit 0
		else
			echo "NO CHAGES BUT FORCING"
			echo "$STATUS"
		fi
	else
		echo "CHANGED. PROCEDING"
		echo "$STATUS"
	fi


SERIAL=0
if [ -f "$FOLDER/serial" ];
then
	SERIAL=`cat $FOLDER/serial | perl -ne "chomp; print"`
	echo "SERIAL OBTAINED: $SERIAL"
else
	echo $SERIAL > $FOLDER/serial
	echo "NO SERIAL: $SERIAL"
fi

echo "CREATING SERIAL"
	SERIAL=$(($SERIAL+1))
	echo "SERIAL INCREMENTED: NEW SERIAL = $SERIAL"
	echo $SERIAL > $FOLDER/serial
	MESSAGE="$SERIAL $SECONDS $DATE $MESSAGE"
echo "MESSAGE $MESSAGE"



echo "CHECKING FOR DIFFERENCES"
	git add .
	git status -s | grep -E "^\?\?" | perl -ne 'print substr($_, 3)' | xargs -n 1 -r -I '{}' bash -c "echo ADDING {};   ls -lah {}; git add {}"
	#git status -s | grep -E "^AD" | perl -ne 'print substr($_, 3)' | xargs -n 1 -r -I '{}' bash -c "echo REMOVING {}; ls -lah {}; git rm {}"
echo "COMMITING $MESSAGE"
	git commit -a --status -m "$MESSAGE"
echo "PULLING git@github.com:sauloal/$FOLDER.git"
	git pull git@github.com:sauloal/$FOLDER.git master
echo "PUSHING"
	git push origin master
echo "COMPLETED"

cd $CURRPWD

# needs to add automatic title with time
# needs to check if folder exists
# needs to search all files and add them, ignoring .git folder

