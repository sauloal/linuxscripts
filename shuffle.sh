#reset

#basic directory where to output scripts
BASEDIR="/home/saulo/Desktop/rolf"

#number of processes to divide into
PROCESSES=3

#list all databases of a given extension (xml)
DATABASES=( $(ls -S -r /mnt/ssd/probes/dumps/*.xml 2>/dev/null) )
#-S SORT BY SIZE. not a good idea

#prefix of bash scripts dinammically generated
RUNNAME=runactuator

count=-1
number=1
total=${#DATABASES[@]}
SPLIT=`echo "$total/$PROCESSES" | bc`
echo $$ THERE ARE $total DATABASES SPLITED IN 3 PROCESSES CONTAINING $SPLIT SEQUENCES EACH



#foreach sequence
for element in $(seq 0 $((${#DATABASES[@]} -1)))
do
	((count++))
	if [ $count == $PROCESSES ]; then
		count=0
		((number++))
	fi

	
	BASENAME=${DATABASES[$element]}
	countp=$((count + 1))

	#generate log
	cat << EOH
		"$countp $number/$SPLIT $BASENAME"

EOH



###########
# code

#
###########




done






