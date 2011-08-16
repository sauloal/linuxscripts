dustmasker -in $1 -outfmt fasta -out $1.dust
DATABASES=( $(ls data/*.nsq) )

DATABASES=(${DATABASES[@]#data/})
DATABASES=(${DATABASES[@]%.nsq})


for element in $(seq 0 $((${#DATABASES[@]} -1)))
 do
 BASENAME=${DATABASES[$element]}
 echo $BASENAME
blastn -db data/$BASENAME -query $1.dust -out answer_$BASENAME\_n.blast  -num_threads 4 -task blastn       -evalue 0.1 -word_size 4  -gapopen 0 -gapextend 4 -penalty -2 -reward 2 -lcase_masking
blastn -db data/$BASENAME -query $1.dust -out answer_$BASENAME\_dc.blast -num_threads 4 -task dc-megablast -evalue 0.1 -word_size 11 -gapopen 0 -gapextend 4 -penalty -2 -reward 2 -lcase_masking
done