ls -l | grep "^d" | perl -nae ' if ( -d "$F[8]/rdiff-backup-data" ) { print "$F[8]\n"; } else { print STDERR "$F[8] DOES NOT CONTAIN RDIFF\n"; }' | xargs -r --verbose du -csh --exclude rdiff-backup-data
ls -l | grep "^d" | perl -nae ' if ( -d "$F[8]/rdiff-backup-data" ) { print "$F[8]\n"; } else { print STDERR "$F[8] DOES NOT CONTAIN RDIFF\n"; }' | xargs -r --verbose -n1 rdiff-backup-statistics

#rdiff-backup-statistics $1
