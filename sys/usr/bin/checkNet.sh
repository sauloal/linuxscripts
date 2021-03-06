#!/bin/bash
IP=192.168.1.254
IFCONFIG="/sbin/ifconfig wlan0"
DATE=`date`;
LOG=/tmp/checkNet.log
if [ -f /etc/intranet ]; then
    echo $DATE " :: INTRANET :: SKIP" >> ${LOG};
    exit 0
    #echo -n
fi





PINGCODE=`ping -nq -c 1 -w 1 -W 1 $IP | grep "received"`
echo $DATE " :: PING :: ${PINGCODE}" >> ${LOG};

GREPCODE=`echo $PINGCODE | gawk '{ if ( /1 received/ ) { print "yes" } else { print "no" } }'`
echo $DATE " :: PING GREP :: ${GREPCODE}" >> ${LOG};


if [ ${GREPCODE} == "yes" ]; then
    echo $DATE " :: PING GREP YES :: SKIP" >> ${LOG};
    exit 0
else
    echo $DATE " :: PING GREP NO :: CHECKING AGAIN" >> ${LOG};

    sleep 30

    PINGCODE=`ping -nq -c 1 -w 1 -W 1 ${IP}`
    GREPCODE=`echo $PINGCODE | gawk '{ if ( /1 responded/ ){ print "yes" } else { print "no" } }'`

    if [ ${GREPCODE} == "no" ]; then
        echo $DATE " :: PING GREP NO RE-CHECK NO :: RESETING" >> ${LOG};
                #/sbin/service network restart 2>&1 1>/dev/null;
        #/sbin/service NetworkManager restart 2>&1 1>/dev/null
    fi
fi