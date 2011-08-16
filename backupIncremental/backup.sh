#!/bin/bash

 ##########################
 # User Defined Variables #
 ##########################

 source /root/etc/backup.conf



 ###################################
 # END USER CONFIGURABLE SECTION   #
 ###################################
 # Do not edit anything below this #
 # unless you're sure you know     #
 # what you're doing.              #
 ###################################

 # Check if the backup directory exists in fstab
 if [[ -n "$MOUNT_BAK_DIR" && $MOUNT_BAK_DIR == "YES" && \
        "`grep -l ${BAK_DIR} /etc/fstab`" == "/etc/fstab" ]];
 then
    echo "$0: Mounting backup directory.";
    mount ${BAK_DIR}/
    MOUNTED=YES
 fi

 # Load date into an array so we dont run it 3 times.
 date=( $(date +"%Y %m %d") )
 YEAR=${date[0]}
 MONTH=${date[1]}
 DAY=${date[2]}

 mkdir -p ${BAK_DIR}/${YEAR}/${MONTH}/
 mkdir -p ${BAK_DIR}/catalogue/${YEAR}/${MONTH}/

 ########################
 # Function Definitions #
 ########################

 # There could be a lot of customization added here.
 diff_full () {
   if [ $DAY -le 7 ];
   then
    echo "$0: Automatically selecting FULL backup.";
    full
   else
    echo "$0: Automatically selecting DIFF backup.";
    diff
   fi
 }

 # full ()
 # Performs full backup of specified directories
 # Creates ${DAY}-full-${NAME}.tar and ${DAY}-full-${NAME}.list
 # Requires: cut, tar
 full () {
 echo "$0: Starting full backup.";
 
 for PAIR in ${BACKME_UP}; do
    DIR=`echo $PAIR | cut -d':' -f1`
    NAME=`echo $PAIR | cut -d':' -f2`

    # Well run tar with -v and output to a file to eliminate this 'find'.
    #find ${DIR} > ${BAK_DIR}/catalogue/${YEAR}/${MONTH}/${DAY}-full-${NAME}.list
    tar --one-file-system -cvpf \
    ${BAK_DIR}/${YEAR}/${MONTH}/${DAY}-full-${NAME}.tar ${DIR} \
    > ${BAK_DIR}/catalogue/${YEAR}/${MONTH}/${DAY}-full-${NAME}.list
 done
 } # end full
 

 # diff ()
 # Performs differential backup of specified directories if full backup exists
 # Creates ${DAY}-diff-${NAME}.tar and ${DAY}-diff-${NAME}.list
 # Requires: cut, find, tar
 diff () {
 echo "$0: Starting differential backup.";
 
 for PAIR in ${BACKME_UP}; do
     DIR=`echo $PAIR | cut -d':' -f1`
     NAME=`echo $PAIR | cut -d':' -f2`

     # If no previous backup exists, do a full backup.
     if [ ! -e ${BAK_DIR}/${YEAR}/${MONTH}/??-full-${NAME}.tar ];
    then
      full
    else
          find ${DIR} -mtime -7 -type f > \
         ${BAK_DIR}/catalogue/${YEAR}/${MONTH}/${DAY}-diff-${NAME}.list &&
          tar -T ${BAK_DIR}/catalogue/${YEAR}/${MONTH}/${DAY}-diff-${NAME}.list \
           --one-file-system -cpf \
           ${BAK_DIR}/${YEAR}/${MONTH}/${DAY}-diff-${NAME}.tar
     fi
 done
 } #end diff
 

 # incr ()
 # Performs incremental backup of specified directories if full backup exists
 # Creates ${DAY}-incr-${NAME}.tar and ${DAY}-incr-${NAME}.list
 # Requires: cut, find, tar
 incr () {
 echo "$0: Starting incremental backup.";
 
 for PAIR in ${BACKME_UP}; do
     DIR=`echo $PAIR | cut -d':' -f1`
     NAME=`echo $PAIR | cut -d':' -f2`

     # If a differential backup has happened this month, the incremental is part of this months backup set
     if [ ! -e ${BAK_DIR}/${YEAR}/${MONTH}/??-full-${NAME}.tar ];
    then
      full
    else
          find ${DIR} -mtime -1 -type f > ${BAK_DIR}/catalogue/${YEAR}/${MONTH}/${DAY}-incr-${NAME}.list && \
          tar -T ${BAK_DIR}/catalogue/${YEAR}/${MONTH}/${DAY}-incr-${NAME}.list \
            --one-file-system -cpf ${BAK_DIR}/${YEAR}/${MONTH}/${DAY}-incr-${NAME}.tar
    fi
 done
 } # end incr


 ###################################
 # Determine how weve been called #
 ###################################

 case `basename $0 | awk -F'-' '{ print $1 }' ` in
 "full")
     if [[ -n "$AUTOSELECT_DIFF_FULL" && $AUTOSELECT_DIFF_FULL == "YES" ]];
     then
       diff_full
     else
       full
     fi
 ;;
 "diff")
     if [[ -n "$AUTOSELECT_DIFF_FULL" && $AUTOSELECT_DIFF_FULL == "YES" ]];
     then
       diff_full
     else
       diff
     fi
 ;;
 "incr")
     incr
 ;;
 esac

 
 if [[ -n "$MOUNTED" && $MOUNTED == "YES" ]];
 then
    echo "$0: Unmounting backup directory.";
    umount ${BAK_DIR}/
 fi