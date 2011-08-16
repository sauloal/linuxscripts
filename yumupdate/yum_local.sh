rpm -qa  | sort | uniq > /tmp/installed_packages_fresh.log

mkdir rpm &>/dev/null

DATABASES=( $(sort /tmp/installed_packages_fresh.log) )

FRESHc=`wc -l /tmp/installed_packages_fresh.log | gawk '{print $1}'`

yum makecache

for element in $(seq 0 $((${#DATABASES[@]} -1)))
 do
     BASENAME=${DATABASES[$element]}
     echo "$element : $FRESHc - $BASENAME"
     yumdownloader --noplugins --destdir ./rpm $BASENAME
     sleep 1
 done