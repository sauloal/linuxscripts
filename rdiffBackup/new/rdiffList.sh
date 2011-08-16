ls -l | grep "^d" | perl -nae ' if ( -d "$F[8]/rdiff-backup-data" ) { print "$F[8]\n"; }' | xargs -r --verbose du -csh --exclude rdiff-backup-data
ls -l | grep "^d" | perl -nae ' if ( -d "$F[8]/rdiff-backup-data" ) { print "$F[8]\n"; }' | xargs -r --verbose -n1 rdiff-backup  --list-increment-sizes

#rdiff-backup --list-increment-sizes $1
#-l, --list-increments
#              List the number and date of partial incremental backups contained in the specified destination directory.  No backup or restore will take place if this option is given.
#
#       --list-increment-sizes
#              List the total size of all the increment and mirror files by time.  This may be helpful in deciding how many increments to keep, and when to --remove-older-than.   Specify-
#              ing a subdirectory is allowable; then only the sizes of the mirror and increments pertaining to that subdirectory will be listed.

