DATABASES=( $(ls original/*.fasta) )

DATABASES=(${DATABASES[@]#original/})
DATABASES=(${DATABASES[@]%.fasta})


for element in $(seq 0 $((${#DATABASES[@]} -1)))
 do
 BASENAME=${DATABASES[$element]}
   echo $BASENAME
   windowmasker -mk_counts true -in original/$BASENAME.fasta -checkdup true -out original/$BASENAME.fasta.masked.wm1 -mem 3096
   windowmasker -ustat original/$BASENAME.fasta.masked.wm1 -in original/$BASENAME.fasta -out  original/$BASENAME.fasta.masked.wm2.ans1 -dust true -outfmt maskinfo_asn1_bin -smem 3096

   dustmasker -in original/$BASENAME.fasta -outfmt maskinfo_asn1_bin -out original/$BASENAME.fasta.masked.dust.ans1
   makeblastdb -in original/$BASENAME.fasta -dbtype nucl -title $BASENAME -parse_seqids -hash_index -out $BASENAME\_db -logfile $BASENAME\_db.log -mask_data original/$BASENAME.fasta.masked.wm2.$
done