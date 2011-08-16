INPUT=$1

cpan2rpm -mk-rpm-dirs=~/rpm
cpan -a
pminst | grep -v -P "^\d" | sort | uniq > /tmp/installed_perl_fresh.log

comm -23 <(sort $INPUT | grep -v -P "^\d" | uniq) <(sort /tmp/installed_perl_fresh.log | uniq) > /tmp/installed_perl_diff.log

DATABASES=( $(sort /tmp/installed_perl_diff.log) )

TOTALc=`wc -l /tmp/installed_perl_diff.log | gawk '{print $1}'`
FRESHc=`wc -l /tmp/installed_perl_fresh.log | gawk '{print $1}'`
ORIGINALc=`wc -l $INPUT | gawk '{print $1}'`

rm /tmp/installed_perl_out.log &>/dev/null

for element in $(seq 0 $((${#DATABASES[@]} -1)))
 do
     BASENAME=${DATABASES[$element]}
     echo "$element : $TOTALc : $FRESHc : $ORIGINALc - $BASENAME"
     #cpan -fi $BASENAME
     #cpan2rpm --no-sign $BASENAME
     cpan2rpm --no-sign --no-depchk $BASENAME
     sleep 1
 done

mkdir perl &>/dev/null
mv ~/rpm/RPMS/noarch/*.rpm ./perl