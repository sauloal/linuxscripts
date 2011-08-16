#Kill programs using more than 99% of the resources saving the system to hang
CPUTHRESHOLD=95
MEMTHRESHOLD=95
#for PROCESS in `ps aux | grep bash | grep -v grep | awk '{print $2}'`
for PROCESS in `ps aux | grep -v grep | grep -v PID | grep -v ps | grep -v root | awk '{print $2}'`
do
    USER=`ps up $PROCESS | grep $PROCESS | awk '{print $1}'`
    CPU=`ps up $PROCESS  | grep $PROCESS | awk '{print $3}' | awk -F. '{print $1}'`
    MEM=`ps up $PROCESS  | grep $PROCESS | awk '{print $4}' | awk -F. '{print $1}'`

    #echo "PROCESS: $PROCESS USER: $USER CPU: $CPU MEM: $MEM :: Killed due to excessive CPU usage"

    if [[ "$CPU" -ge "$CPUTHRESHOLD" ]]
    then
        echo "PROCESS: $PROCESS USER: $USER CPU: $CPU MEM: $MEM :: Killed due to excessive CPU usage"
        # kill -9 $PROCESS
    fi

    if [[ "$MEM" -ge "$MEMTHRESHOLD" ]]
    then
        echo "PROCESS: $PROCESS USER: $USER CPU: $CPU MEM: $MEM :: Killed due to excessive MEMORY usage"
        # kill -9 $PROCESS
    fi
done