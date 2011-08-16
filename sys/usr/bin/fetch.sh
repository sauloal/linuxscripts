#!/bin/bash

PROGRAM=$1

#while ((`pgrep $PROGRAM`));
while ((1));
do
#top -b -n 1 | grep $PROGRAM
#top -b -n 1 | grep $PROGRAM | gawk '{print $1"\t"$5"\t"$6"\t"$7"\t"$9"\t"$10"\t"$11"\t"$12}'
PID=`pgrep $PROGRAM`

if (($PID))
then
INFO=`top -b -n 1 | grep $PROGRAM | gawk '{print $9"\t"$10"\t"$11"\t"$12}'`
MEM=`pmap -d $PID | tail -1 | gawk '{print $2"\t"$4}'`
echo -e "$PID\t$MEM\t$INFO"
fi

sleep 1
done