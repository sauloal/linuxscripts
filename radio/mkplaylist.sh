FOLDER=/share/mnt/jean_mp3
find ${FOLDER}/ -iname '*.mp3' | sort -R | sort -R > ${FOLDER}/playlist.m3u