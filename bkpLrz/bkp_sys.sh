#!/bin/bash
DIA=`date '+%Y-%m-%d'`
echo "BACKING UP /HOME ON $DIA"
tar -cvpjf $DIA/$DIA\_home.tar.gz --directory /home --exclude=.mozilla/firefox
echo "BACKING UP /VAR  ON $DIA"
tar -cvpjf $DIA/$DIA\_var.tar.gz --directory /var
echo "BACKING UP /BOOT ON $DIA"
tar -cvpjf $DIA/$DIA\_boot.tar.gz --directory /boot
echo "BACKING UP /USR  ON $DIA"
tar -cvpjf $DIA/$DIA\_usr.tar.gz --directory /usr
echo "BACKING UP /ROOT ON $DIA"
tar -cvpjf $DIA/$DIA\_root.tar.gz --directory / --exclude=/proc --exclude=/sys --exclude=/dev/pts --exclude=/home --exclude=/var --exclude=/usr --exclude=/boot --exclude=/dev/tmpfs --exclude=/media --exclude=/mnt

#tar -ztvpf home.tar.gz --directory /home