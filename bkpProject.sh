DIA=`date '+%Y-%m-%d'`
TIME=`date +%c`
echo $TIME  >> ./probe_backup_${DIA}.log
FOLDERBASE="./"
#FOLDERBASE="/home/saulo/Desktop/rolf/"
BACKUPBASE="backup_rolf_${DIA}"


echo "BACKING UP ${FOLDERBASE} TO ${BACKUPBASE}"

FILES[0]="${FOLDERBASE}probe_backup.sh"
FILES[1]="${FOLDERBASE}probe_extractor.pl"
FILES[2]="${FOLDERBASE}probe_extractor_actuator.pl"
FILES[3]="${FOLDERBASE}probe_extractor_actuator_new.pl"
FILES[4]="${FOLDERBASE}probe_insert.pl"
FILES[5]="${FOLDERBASE}probe_result.pl"
FILES[6]="${FOLDERBASE}probe_result_actuator.pl"
FILES[7]="${FOLDERBASE}probe_result_first.pl"
FILES[8]="${FOLDERBASE}probe_run.pl"
FILES[9]="${FOLDERBASE}Synthetic_probe_design.pdf"
FILES[10]="${FOLDERBASE}tab_vs_sql.log"
FILES[11]="${FOLDERBASE}temp.sql"
FILES[12]="${FOLDERBASE}temp2.sql"
FILES[13]="${FOLDERBASE}update.sql"
FILES[14]="${FOLDERBASE}input/SEQUENCE_TYPE.idx"
FILES[15]="${FOLDERBASE}input/taxonomy.idx"
FILES[16]="${FOLDERBASE}sql/*.sql"
FILES[17]="${FOLDERBASE}sql/*.sh"
FILES[18]="${FOLDERBASE}config"
FILES[19]="${FOLDERBASE}Benchmark*"
FILES[20]="${FOLDERBASE}formula.ods"
FILES[21]="${FOLDERBASE}java_vs_perl.log"
#FILES[22]="${FOLDERBASE}"

FOLDERS[0]="${FOLDERBASE}tools/"
FOLDERS[1]="${FOLDERBASE}blat/"
FOLDERS[2]="${FOLDERBASE}filters/"
FOLDERS[3]="${FOLDERBASE}sql/probe/"
FOLDERS[4]="${FOLDERBASE}sql/mysql/"
FOLDERS[3]="${FOLDERBASE}Taxonomy/"
#FOLDERS[3]="${FOLDERBASE}"

PRECLEAN[0]="rm -f ${FOLDERBASE}blat/*.fa"
PRECLEAN[1]="rm -f ${FOLDERBASE}blat/*.psl"
PRECLEAN[2]="rm -f ${FOLDERBASE}blat/*.lst"
PRECLEAN[3]="rm -Rf ${FOLDERBASE}*~"
#PRECLEAN[4]="rm -f ${FOLDERBASE}blat/*.fa"
#PRECLEAN[5]="rm -f ${FOLDERBASE}blat/*.fa"

POSTCLEAN[0]="rm -f ${BACKUPBASE}/blat/*.fa"
POSTCLEAN[1]="rm -f ${BACKUPBASE}/blat/*.psl"
POSTCLEAN[2]="rm -f ${BACKUPBASE}/blat/*.lst"


PRECLEAN_COUNT=${#PRECLEAN[@]}
FOLDER_COUNT=${#FOLDERS[@]}
FILE_COUNT=${#FILES[@]}
POSTCLEAN_COUNT=${#POSTCLEAN[@]}

echo "
THERE ARE:
${PRECLEAN_COUNT} CLEANS TO BE PERFORMED BEFORE BACKUP,
${FOLDER_COUNT} FOLDERS TO BE COPIED,
${FILE_COUNT} FILES TO BE COPIED AND
${POSTCLEAN_COUNT} CLEANS TO BE PERFORMED AFTER BACKUP"


mkdir ${BACKUPBASE}

INDEX_PRECLEAN=0
INDEX_FOLDER=0
INDEX_FILE=0
INDEX_POSTCLEAN=0


while [ "$INDEX_PRECLEAN" -lt "$PRECLEAN_COUNT" ]
do
  echo "    PRE CLEAN ${INDEX_PRECLEAN}: ${PRECLEAN[$INDEX_PRECLEAN]}"
  #${PRECLEAN[$INDEX_PRECLEAN]}
  INDEX_PRECLEAN=$((INDEX_PRECLEAN + 1))
done

while [ "$INDEX_FOLDER" -lt "$FOLDER_COUNT" ]
do
  echo "    FOLDER ${INDEX_FOLDER}: ${FOLDERS[$INDEX_FOLDER]}"
  cp -a --parents -u ${FOLDERS[$INDEX_FOLDER]} ${BACKUPBASE}  
  INDEX_FOLDER=$((INDEX_FOLDER + 1))
done

while [ "$INDEX_FILE" -lt "$FILE_COUNT" ]
do
  echo "    FILE ${INDEX_FILE}: ${FILES[$INDEX_FILE]}"
  cp -cdp --parents -u ${FILES[$INDEX_FILE]} ${BACKUPBASE}
  INDEX_FILE=$((INDEX_FILE + 1))
done


while [ "$INDEX_POSTCLEAN" -lt "$POSTCLEAN_COUNT" ]
do
  echo "    POST CLEAN ${INDEX_POSTCLEAN}: ${POSTCLEAN[$INDEX_POSTCLEAN]}"
  ${POSTCLEAN[$INDEX_POSTCLEAN]}
  INDEX_POSTCLEAN=$((INDEX_POSTCLEAN + 1))
done



echo "    PACKING OUTPUT FOLDER ${BACKUPBASE} TO ${BACKUPBASE}.tar.bz2"
tar -c ${BACKUPBASE} | bzip2 > ${BACKUPBASE}.tar.bz2

echo "    DELETING OUTPUT FOLDER ${BACKUPBASE}"
rm -rf ${BACKUPBASE}