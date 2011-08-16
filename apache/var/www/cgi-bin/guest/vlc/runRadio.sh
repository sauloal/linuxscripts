killall vlc 1>/dev/null 2>/dev/null
FOLDER=/share/mnt/jean_mp3

MUSIC=${FOLDER}/playlist.m3u
LOGFILE=${FOLDER}/vlcstream.log
rm -rf ${LOGFILE}

TTL=12
CACHE=3000
STREAMPORT=0.0.0.0:2020

#INTERFACE="-I rc"
#INTERFACE="-I telnet"
INTERFACE="-I http"
HTTPPORT=127.0.0.1:2121
TELNETADD=127.0.0.1
TELNETPORT=2121
TELNETPWD=******
RCADD=127.0.0.1:2121


#cvlc -I rc /share/mnt/jean_mp3/playlist.m3u --sout '#std{access=http,mux=raw}' --sout-standard-dst 0.0.0.0:2020 --rc-host 127.0.0.1:2121 
#--telnet-password ****** --sout-keep --ttl 12 --random --file-caching 3000 --sout-standard-name=test2 --sout-shout-name=test2

#OPTIONS="--rc-host ${RCADD} --sout-keep --ttl $TTL --random --daemon"
#OPTIONS="--telnet-host ${TELNETADD} --telnet-port ${TELNETPORT} --telnet-password ${TELNETPWD} --sout-keep --ttl $TTL --random --daemon"
OPTIONS="--http-host ${HTTPPORT} --sout-keep --ttl $TTL --random"
#OPTIONS="--sout-keep --ttl $TTL --random --daemon"

CACHEOPT="--file-caching ${CACHE} --sout-mux-caching ${CACHE}"
DEST="--sout-standard-dst $STREAMPORT"
SOUT="--sout '#std{access=http,mux=raw}'"

COMMAND="cvlc ${INTERFACE} ${MUSIC} ${SOUT} ${DEST} ${OPTIONS} ${CACHEOPT} > ${LOGFILE}"

echo ${COMMAND}

#cvlc ${COMMAND} 2>>${LOGFILE} 1>>${LOGFILE} &
#cvlc ${COMMAND} 2>>${LOGFILE} 1>>${LOGFILE} &
#cvlc -I http ${COMMAND} 2>>${LOGFILE} 1>>${LOGFILE} &
#cvlc ${COMMAND} 2>>${LOGFILE} 1>>${LOGFILE} &





#cvlc ${MUSIC} ${SOUT} ${DEST} ${OPTIONS} ${CACHEOPT} 2>>${LOGFILE} 1>>${LOGFILE} &

#--file-caching 1000
#1000 ms of caching

#--sout-mux-caching 1000
#1000 ms of cahing

#--random
#--loop
#--daemon

#--http-host 127.0.0.1
##--telnet-port 2121
##--telnet-password ******



#-vvv
#--sout-keep
