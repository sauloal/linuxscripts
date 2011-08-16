find -P / -readable -type f -print0 | grep -zvE "^\./proc|^\./sys|^\./dev|/\.ccache/" | xargs -0 -r -n 1 sha256sum  | pv -ptbr > allfiles.tab


sort --compress-program=gzip -k 1,64 allfiles.tab > allfiles.tab.sort


cat allfiles.tab.sort | ./ag.pl > allfiles.tab.sort.ag


cat allfiles.tab.sort.ag | gawk '{if ($2 > 1) {print}}' > allfiles.tab.sort.ag.shared


cat allfiles.tab.sort.ag | gawk '{if ($2 == 1) {print}}' > allfiles.tab.sort.ag.unique
