#!/bin/bash
dd if=/dev/zero of=/root/xen/clean.img bs=1M count=40960
losetup /dev/loop0 /root/xen/clean.img
partimage restore /dev/loop0 /root/xen/sda1_WXP64_root.img
losetup -d /dev/loop0