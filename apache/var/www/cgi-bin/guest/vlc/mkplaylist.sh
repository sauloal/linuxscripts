BASEFOLDER=/share/mnt/jean_mp3
SUBFOLDER=MP3
find ${BASEFOLDER}/${SUBFOLDER}/ -iname '*.mp3' | sort -R | sort -R > ${BASEFOLDER}/playlist.m3u
# find mp3 in folder                              | random the list > save as m3u
#find /share/jean_mp3 *.mp3 > /share/playlist.m3u
#locate *.mp3 | grep /share/jean_mp3 > /share/playlist.m3u
