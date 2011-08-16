rdiff-backup --remove-older-than $1 $2 
# --remove-older-than time_spec
#              Remove  the  incremental  backup  information  in the destination directory that has been around longer than the given time.  time_spec can be either an absolute time, like
#              "2002-01-04", or a time interval.  The time interval is an integer followed by the character s, m, h, D, W, M, or  Y,  indicating  seconds,  minutes,  hours,  days,  weeks,
#              months, or years respectively, or a number of these concatenated.  For example, 32m means 32 minutes, and 3W2D10h7s means 3 weeks, 2 days, 10 hours, and 7 seconds.  In this
#              context, a month means 30 days, a year is 365 days, and a day is always 86400 seconds.
#
#              rdiff-backup cannot remove-older-than and back up or restore in a single session.  In order to both backup a directory and remove old files in it, you must run rdiff-backup
#              twice.
#
#              By  default, rdiff-backup will only delete information from one session at a time.  To remove two or more sessions at the same time, supply the --force option (rdiff-backup
#              will tell you if --force is required).
#
#              Note that snapshots of deleted files are covered by this operation.  Thus if you deleted a file two weeks ago, backed up immediately afterwards, and then  ran  rdiff-backup
#              with --remove-older-than 10D today, no trace of that file would remain.  Finally, file selection options such as --include and --exclude don’t affect --remove-older-than.