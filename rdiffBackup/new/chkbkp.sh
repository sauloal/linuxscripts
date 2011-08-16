mkdir "ERROR" 2>/dev/null

find ./ -maxdepth 1 -type d | while read d;
do
	find $d/rdiff-backup-data/ $maxdepth 2 -name '*.gz' 2>/dev/null | while read a; 
	do
        	#echo -e -n "$d :: $a:\n\t\t"
		RESULT=`gzip -v --test "$a" 2>&1 1>/dev/null`
		FILE=`echo "${RESULT}" | perl -ne 'chomp; if(/[gzip: ]*(.+\.gz)\:\s+.+$/) { print "\$1"; }'`
		RESP=`echo "${RESULT}" | perl -ne 'chomp; if(/[gzip: ]*.+\.gz\:\s+(.+)$/) { print "\$1"; }'`
		#echo -e -n "$d :: ${RESULT}\n"
		#echo "RESU: \"$RESULT\""
		#echo "FILE: \"$FILE\""
		#echo "RESP: \"$RESP\""
		#echo ""
		if [ "$RESP" != "OK" ];
		then
			echo -e "\tFILE: ${FILE} :: RESPONSE: ${RESP}\n"
			mv "${FILE}" ERROR/
		fi
	done
done


