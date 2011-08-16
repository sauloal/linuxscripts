SITE=www.google.com
INDEXPAGE=index.html

wget --base=$SITE --continue --force-directories --recursive \
--level=5 --convert-links \
--mirror -R .avi,.jpg --page-requisites \
--restrict-file-names=unix \
--html-extension $SITE/$INDEXPAGE


