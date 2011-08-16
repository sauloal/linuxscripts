ln -s /usr/bin/mountSys /etc/init.d/
ln -s /usr/bin/umountSys /etc/init.d/
ln -s /etc/init.d/mountSys /etc/rc5.d/S99mountsys
ln -s /etc/init.d/umountSys /etc/rc6.d/K01umountsys