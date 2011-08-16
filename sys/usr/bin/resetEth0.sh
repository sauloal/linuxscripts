#!/bin/sh
#*/5 * * * * /usr/bin/reseteth0.sh 1>/dev/null 2>/dev/null > /dev/null

IFCONFIG="/sbin/ifconfig eth0"
DATE=`date`;

ISIT=`$IFCONFIG | grep "UP" | wc -l`;

if test $ISIT -gt 0;
then
   echo $DATE " ETH0 OK" >> /tmp/reseteth0.log;
else
   echo $DATE " bringing eth0 up" >> /tmp/reseteth0.log;
   /sbin/service network start 1>/dev/null 2>/dev/null >/dev/null;
fi