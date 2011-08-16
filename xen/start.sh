echo 1 > /proc/sys/net/ipv4/ip_forward
xm create wxp64.cfg
xm sched-credit -d wxp64 -w 4096 -c 400
xm sched-credit -d Domain-0 -w 128 -c 0