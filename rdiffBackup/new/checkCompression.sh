COMP=`du -s . | gawk '{print $1}'`
REAL=`du -s --apparent-size . | gawk '{print $1}'`

COMPM=$(($COMP/1024))
REALM=$(($REAL/1024))

COMPG=$(($COMPM/1024))
REALG=$(($REALM/1024))

COMPP=$(($COMP/$REAL))
REALP=$(($REAL/$COMP))

COMPp=`echo "scale=2; $COMP / $REAL" | bc`
REALp=`echo "scale=2; $REAL / $COMP" | bc`
echo -ne "REAL       ${REAL} B\t${REALM} MB\t${REALG} GB\t${REALp} %\n"
echo -ne "COMPRESSED ${COMP} B\t${COMPM} MB\t${COMPG} GB\t${COMPp} %\n"


