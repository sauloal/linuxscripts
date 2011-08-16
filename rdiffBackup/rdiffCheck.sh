ls -l | grep "^d" | perl -nae ' if ( -d "$F[7]/rdiff-backup-data" ) { print "$F[7]\n"; }' | xargs -r --verbose -n1 rdiff-backup --check-destination-dir

#rdiff-backup --check-destination-dir $1
#--check-destination-dir
#              If an rdiff-backup session fails, running rdiff-backup with this option on the destination dir will undo the failed directory.  This happens automatically if you attempt to
#              back up to a directory and the last backup failed.