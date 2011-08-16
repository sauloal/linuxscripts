#!/bin/bash

if [ -f /etc/mountSys ]; then

        if [[ ! -z `mount | grep "full_sys.img"` ]]; then
                echo "MOUNTED.. umounting"

                echo ".........RUNNING STOP SCRIPT"
                echo "./stop" | chroot /home/aflitos/Desktop/sys/mnt
                echo "./stop" | chroot /home/aflitos/Desktop/sys/mnt
                echo "./stop" | chroot /home/aflitos/Desktop/sys/mnt

                echo ".........KILLING PROCESSES"
                fuser -k /home/aflitos/Desktop/sys/mnt

                echo ".........UMOUNTING SYS"
                umount /home/aflitos/Desktop/sys/mnt
                echo ".........DONE"
        else
                echo "UMOUNTED"
        fi
fi