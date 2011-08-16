dd if=/dev/zero of=disk.img bs=1024 count=51200
parted disk.img mklabel msdos
parted disk.img mkpart primary ext2 0 53

parted disk.img set 1 boot on
parted disk.img mkfs 1 ext2
mkdir mnt

mount -o loop,offset=16384 -t ext2 disk.img mnt
mkdir mnt/grub
cp /boot/grub/stage1 mnt/grub
cp /boot/grub/stage2 mnt/grub
cp /boot/grub/e2fs_stage1_5 mnt/grub

echo "default=0
timeout=0
#hiddenmenu

#title minimal-kernel
#    kernel /minimal-kernel
    
title WXP64                                    
    map (hd0) (hd1) # Tell the first hard drive to pretend to be the second
    map (hd1) (hd0) # Tell the second hard drive to pretend to be the first
    rootnoverify (hd1,0)
    makeactive
    chainloader +1
                                                                    
" > mnt/grub/grub.conf

cd mnt/grub
ln -s grub.conf menu.lst
cd ../..

echo "device (hd0) disk.img
root (hd0,0)
setup (hd0)
quit
" >/tmp/grub.input

grub --device-map=/dev/null < /tmp/grub.input

#cp minimal-kernel mnt/

umount mnt
rmdir mnt