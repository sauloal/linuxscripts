INFOLDER=/bkp_latest
OUFOLDER=/bkp_latest_b

OUT=`date +"%Y_%m_%d_%H%M"`
echo "IN FOLDER $INFOLDER OUT FOLDER $OUFOLDER DATE $OUT"
rm -rf  $OUFOLDER/$OUT &>/dev/null
mkdir   $OUFOLDER/$OUT &>/dev/null
#CMD="cp -aR ${FOLDER}/*.xml ${FOLDER}/*.sh ${FOLDER}/*.pl ${FOLDER}/*.pm ${FOLDER}/BKP ${OUT} &>/dev/null"
CMD1="ls -l ${INFOLDER} | grep -Ev \"\.tbz|\.log|^d|\.tgz|\~\$\" | gawk '{print \$9}' | xargs -r -I{} cp -a ${INFOLDER}/{} ${OUFOLDER}/${OUT}/ &> ${OUFOLDER}/${OUT}/CMD1.log"
CMD2="rpm -qa --qf '%{NAME}\n' | sort > ${OUFOLDER}/${OUT}/rpm.list 2>${OUFOLDER}/${OUT}/CMD2.log"

echo "CMD1 ${CMD1}"
echo "CMD2 ${CMD2}"
eval $CMD1
eval $CMD2

