ls -l | grep "^d" | perl -nae ' if ( -d "$F[7]/rdiff-backup-data" ) { print "$F[7]\n"; }' | xargs -r --verbose du -csh --exclude rdiff-backup-data
ls -l | grep "^d" | perl -nae ' if ( -d "$F[7]/rdiff-backup-data" ) { print "$F[7]\n"; }' | xargs -r --verbose -n1 rdiff-backup-statistics

#rdiff-backup-statistics $1