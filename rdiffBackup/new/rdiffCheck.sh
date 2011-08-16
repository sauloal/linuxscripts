ls -l | grep "^d" | perl -nae ' if ( -d "$F[8]/rdiff-backup-data" ) { print "$F[8]\n"; } else { print STDERR "$F[8] DOES NOT CONTAIN RDIFF\n" }' | xargs -r --verbose -n1 rdiff-backup --check-destination-dir

#rdiff-backup --check-destination-dir $1
#--check-destination-dir
#              If an rdiff-backup session fails, running rdiff-backup with this option on the destination dir will undo the failed directory.  This happens automatically if you attempt to
#              back up to a directory and the last backup failed.

