#!/bin/bash
#checks and prints the stage area
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

echo "CHECKING FOR DIFFERENCES"
	cd $FOLDER
	git add .
	git status -s | grep -E "^\?\?" | perl -ne 'print substr($_, 3)' | xargs -n 1 -r -I '{}' bash -c "echo ADDING {};   ls -lah {}; git add {}"
	#git status -s | grep -E "^AD" | perl -ne 'print substr($_, 3)' | xargs -n 1 -r -I '{}' bash -c "echo REMOVING {}; ls -lah {}; git rm {}"
	cd ..

echo "DONE"
