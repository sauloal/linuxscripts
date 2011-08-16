FILE1=$1
FILE2=$2

if [ ! -f "$FILE1" ];
then
	echo "FILE 1 NOT DEFINED"
	exit 1
fi

if [ ! -f "$FILE2" ];
then
        echo "FILE 2 NOT DEFINED"
	exit 2
fi

diff -Bbdy --suppress-common-lines $FILE1 $FILE2 
