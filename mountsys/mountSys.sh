#!/bin/bash

if [ -f /etc/mountSys ]; then

        if [[ ! -z `mount | grep "full_sys.img"` ]]; then
                echo "MOUNTED"
        else
                echo "NOT MOUNTED... MOUNTING"
                echo ".............. MOUNTING SYS"
                mount -o loop /home/aflitos/Desktop/sys/full_sys.img /home/aflitos/Desktop/sys/mnt/
                echo ".............. RUNNING INIT SCRIPT"
                echo "./init" | chroot  /home/aflitos/Desktop/sys/mnt/
                echo ".............. DONE"
        fi
fi