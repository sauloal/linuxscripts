sudo /sbin/losetup /dev/loop7 $1
sudo mount -o loop,offset=16384 -t ext2 $1 $2
if [ $3 ]; then

    sudo /usr/sbin/chroot $2
    ./umnt $2
fi