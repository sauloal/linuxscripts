ORIGIN="/bkp_latest/"
DESTIN="/bkp_latest_c/"
fusecompress -o allow_other,fc_c:lzo $ORIGIN $DESTIN
#umount bkp_latest_c/
