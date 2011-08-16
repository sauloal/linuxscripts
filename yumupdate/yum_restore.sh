INPUT=$1

yum makecache

rpm -qa --queryformat "%{name}\n" | sort | uniq > /tmp/installed_packages_fresh.log

comm -23 <(sort $INPUT | uniq) <(sort /tmp/installed_packages_fresh.log | uniq) > /tmp/installed_packages_diff.log

DATABASES=( $(sort /tmp/installed_packages_diff.log) )

TOTALc=`wc -l /tmp/installed_packages_diff.log | gawk '{print $1}'`
FRESHc=`wc -l /tmp/installed_packages_fresh.log | gawk '{print $1}'`
ORIGINALc=`wc -l $INPUT | gawk '{print $1}'`

for element in $(seq 0 $((${#DATABASES[@]} -1)))
 do
     BASENAME=${DATABASES[$element]}
     echo "$element : $TOTALc : $FRESHc : $ORIGINALc - $BASENAME"
     yum -y install $BASENAME
     sleep 1
 done