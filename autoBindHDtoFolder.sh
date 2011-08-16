TIME=`date +%c`
echo $TIME  >> /tmp/bindHdsAuto.log

MOUNTDIR=/media/HULK\(1T\)/
SHAREDIR=/var/www/html/shares/FILMS
LOGNAME=HULK

sdparm --command=start /dev/sdb1 1>> /tmp/bindHdsAuto.log 2>> /tmp/bindHdsAuto.log
sdparm --command=start /dev/sdc1 1>> /tmp/bindHdsAuto.log 2>> /tmp/bindHdsAuto.log
sdparm --command=start /dev/sdc2 1>> /tmp/bindHdsAuto.log 2>> /tmp/bindHdsAuto.log
sdparm --command=start /dev/sdc3 1>> /tmp/bindHdsAuto.log 2>> /tmp/bindHdsAuto.log

if [[ -d $MOUNTDIR ]]; 
then
  if [[ -n `mount | grep "$SHAREDIR"` ]];
  then
	echo "    YES $LOGNAME . MOUNTED" >> /tmp/bindHdsAuto.log
  else
	mount -o users --bind $MOUNTDIR $SHAREDIR 1>> /tmp/bindHdsAuto.log 2>>/tmp/bindHdsAuto.log
	echo "    YES $LOGNAME . UMOUNTED . MOUNTED" >> /tmp/bindHdsAuto.log
  fi
else
  if [[ -n `mount | grep "$SHAREDIR"` ]];
  then
	umount $SHAREDIR 1>> /tmp/bindHdsAuto.log 2>>/tmp/bindHdsAuto.log
	echo "    NO $LOGNAME . MOUNTED . UMOUNTED" >> /tmp/bindHdsAuto.log
  else
	echo "    NO $LOGNAME . NO MOUNTED" >> /tmp/bindHdsAuto.log  
  fi;

  echo "    NO $LOGNAME" >> /tmp/bindHdsAuto.log
fi;