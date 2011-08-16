#!/usr/bin/perl -w
# 2010 08 16 2104
use strict;
use Cwd 'abs_path';
use File::Basename;
use Time::Local;
use FindBin qw($Bin);
use lib "$Bin";
my $bin = $Bin;
use loadconf;

my $enableRdiff    = 1;
my $sleepGraceTime = 1_000;
my $defaultUser    = "500:500";

my $outputFolder   = $bin;
my $startTime      = localtime();
my $startTimeS     = time;
#BEHAVIOR
#   EXECUTE PRE-EXECUTE
#   --- NOT --- READ BASE FOLDER EXCLUDING FOLDERS IN EXCLUDE.FOLDER
#       EXCLUDE FILES IN EXCLUDE.EXTENSION
#       EXCLUDE FILES BYFOLDER.EXT
#       RECOVER FILES IN INCLUDE.EXT
#       RECOVER FILES BYFOLDER
#   EXECUTE PRE-RUN
#       RUN BACKUP
#   EXECUTE POS-RUN
#   EXECUTE POS-EXECUTE


my ($gSec, $gMin, $gHour, $gMday, $gMon, $gYear, $gWday, $gYday, $gIsdst) = localtime(time);
$gYear += 1900;
$gMon  += 1;
my $timeStamp = sprintf "%04d_%02d_%02d", $gYear, $gMon, $gMday;
my $verbose   = 1;
my $setupFile;


for (my $a = 0; $a < @ARGV; $a++)
{
    my $arg = lc($ARGV[$a]);

    if ( $arg eq "-v")
    {
        $verbose = $ARGV[$a+1];
        $a++;
        next;
    }
    elsif ( index($arg, ".xml") != -1 )
    {
        $setupFile = $ARGV[$a];
    }
}




print "OUTPUT FOLDER $outputFolder\n" if $verbose;


if ( defined $setupFile )
{
    #die "USAGE: $0 <SETUP FILE.XML>"         if ( !    $setupFile );
    die "SETUPFILE $setupFile DOESNT EXISTS" if ( ! -f $setupFile );
} else {
    $setupFile = "$bin/bkpJob";
}


my $projLogFile = "$setupFile\_$timeStamp.log";
open PROJLOG, ">$projLogFile" or die "COULD NOT OPEN LOG FILE :: $projLogFile : $!";

&printLog(1,"START TIME ::  $startTime\n");
&printLog(1,"LOG FILE ::  $projLogFile. $timeStamp\n");
&printLog(1,"LOADING SETUP FILE $setupFile. $timeStamp\n");

my %projects;

if ($setupFile eq "$bin/bkpJob" )
{
    my $prjs = &listFiles($outputFolder, ".xml");

    if ( ! -f "$outputFolder/bkpJob.xml" )
    {
        open FH, ">$outputFolder/bkpJob.xml" or die "COULD NOT CREATE CONFIG FILE: $!\n";
        print FH
"<root>
    <bkpJob>
        <enableRDiff>       1       </enableRDiff>
        <sleepGraceTime>    1000    </sleepGraceTime>
    </bkpJob>
</root>\n";
        close FH;
    };

    foreach my $prj ( @$prjs )
    {
        next if ( $prj eq "$outputFolder/bkpJob.xml" );
        my %tmp = &loadconf::loadConf($prj);
        foreach my $key ( %tmp )
        {
            $projects{$key} = $tmp{$key};
        }
    }


    my %tmpH = &loadconf::loadConf("$outputFolder/bkpJob.xml");
    foreach my $k ( sort keys %tmpH )
    {
        my $v = $tmpH{$k};
        if ( $k =~ /bkpJob/ )
        {
            $k =~ s/bkpJob\.//;
            &printLog(2,"SETUP KEY \"$k\" = $v\n");
            if    ( $k eq "enableRDiff" )    { $enableRdiff    = $v ; &printLog(3,"ENABLE RDIFF :: $v\n"    ) }
            elsif ( $k eq "sleepGraceTime" ) { $sleepGraceTime = $v ; &printLog(3,"SLEEP GRACE TIME :: $v\n") };
        } else {
            &printLog(2,"PROJECT KEY \"$k\" = $v\n");
            $projects{$k} = $v;
        }
    }
} else {
    %projects = &loadconf::loadConf($setupFile);
}

&printLog(1,"SETUP FILE LOADED. ", scalar(keys %projects)," LINES LOADED\n");


if ( ! $enableRdiff )
{
    &printLog(1,"ENABLE RDIFF :: !! FALSE !!. NO RDIFF COMMAND WILL ACTUALLY BE ISSUED\n");
}



foreach my $line (keys %projects)
{
    if ( $line =~ /^(\S+)\.exec$/ )
    {
        my $projectST = time;
        my $project   = $1;
        my $exec      = $projects{"$project.exec"};

        next if ( ! $exec );

        #rootProject
        my %nfo;
        foreach my $proj (keys %projects)
        {
            if ($proj =~ /^$project\.(.*)/)
            {
                 $nfo{$1} = $projects{$proj};
            } else {
                 next;
            };
        };

        &printLog(1,"$project :: RUNNING PROJECT\n");

        &printLog(2,"$project :: LOADING SETUP\n");
        my ($baseFolder, $func, $byFolder) = &loadSetup(\%nfo);
        &printLog(2,"$project :: SETUP LOADED\n");

        if ( ! defined $baseFolder ) { &printLog(0,"$project :: NO BASEFOLDER DEFINED\n"); die; };

        my $preExec    = $nfo{preExec}   || ''; # command to run prior to the analysis
        my $posExec    = $nfo{posExec}   || ''; # command to run after the analysis
        my $run        = $nfo{run}       || 0;  # run the backup
        my $preRun     = $nfo{preRun}    || ''; # command to run prior to run
        my $posRun     = $nfo{posRun}    || ''; # command to run after run
        my $addUnknown = $nfo{addUnkown} || 0;  #add not explicit or not
        my $autoClean  = $nfo{autoClean} || 0;  #add not explicit or not

        #&printLog(3, "  $project :: BASEFOLDER : \"$baseFolder\"" ,"\n");
        #&printLog(3, "  $project :: PREEXEC    : \"$preExec\""    ,"\n");
        #&printLog(3, "  $project :: POSEXEC    : \"$posExec\""    ,"\n");
        #&printLog(3, "  $project :: RUN        : \"$run\""        ,"\n");
        #&printLog(3, "  $project :: PRERUN     : \"$preRun\""     ,"\n");
        #&printLog(3, "  $project :: POSRUN     : \"$posRun\""     ,"\n");
        #&printLog(3, "  $project :: ADDUNKNOWN : \"$addUnknown\"" ,"\n");
        #&printLog(3, "  $project :: AUTOCLEAN  : \"$autoClean\""  ,"\n");

        my $stpOut;
        foreach my $key (sort keys %nfo)
        {
            my $strOut = "SETUP  : ". sprintf("%-40s", $key). " = \"". $nfo{$key}. "\"";
            $stpOut   .= "$strOut\n";
            &printLog(2, "$project :: $strOut\n");
        }


        if ( ! -d $baseFolder ) { &printLog(0,"$project :: FOLDER $baseFolder DOESNT EXISTS\n"); die; };

        if ((defined $preExec) && (length($preExec) >= 3))
        {
            &printLog(2,"$project :: RUNNING PREEXEC : $preExec\n");
            &printLog(2,    "#"x3      , "PRE EXEC "  , "#"x3      , "\n");
            my $preExecOut = `$preExec`;
            &printLog(2,    "\"", $preExecOut , "\"\n");
            &printLog(2,"$project :: PREEXEC RUNNED\n");
        }



        &printLog(2,"$project :: LISTING FOLDER $baseFolder\n");
        my $excFolder = $func->{exclude} ? $func->{exclude}{folder} : undef;
        my $all       = &listAll($baseFolder, $baseFolder, $excFolder);
        &printLog(2,"$project :: FOLDER $baseFolder LISTED\n");








        foreach my $function (keys %$func)
        {
            &printLog(3, "  FUNCTION :: $function\n");
            my $objects = $func->{$function};
            foreach my $object ( keys %$objects )
            {
                &printLog(3,"    OBJECT TYPE:: $object\n");
                my $points = $objects->{$object};
                foreach my $point (@$points)
                {
                        &printLog(3,"      OBJECT : " . $point . "\n");
                }
            }
        }



        foreach my $folder (sort keys %$byFolder)
        {
            &printLog(3,"  by FOLDERS :: $folder\n");
            my $functions = $byFolder->{$folder};
            foreach my $func ( sort keys %$functions )
            {
                &printLog(3,"    FUNCTION ", $func, "\n");
                my $objTypes = $functions->{$func};
                foreach my $objType ( sort keys %$objTypes )
                {
                    &printLog(3,"      OBJECT TYPE ", $objType, "\n");
                    my $objs = $objTypes->{$objType};
                    foreach my $obj ( sort @$objs )
                    {
                        &printLog(3,"        OBJECT ", $obj, "\n");
                    }
                }
            }
        }







        &printLog(2,"$project :: FILTERING FILES\n");
        my $selectedFiles = &filterFiles($all, $func, $byFolder, $baseFolder);
        &printLog(2,"$project :: FILES FILTERED\n");

        my $validFiles     = $selectedFiles->[1] || [];
        my @validFileNames;
        map {
                &printLog(4,"  VALID $_->[2]\n");
                push(@validFileNames, $_->[2])
             } @$validFiles;

        my $notValidFiles     = $selectedFiles->[0] || [];
        my @notValidFileNames;
        map {
                &printLog(4,"  NOTVALID $_->[2]\n");
                push(@notValidFileNames, $_->[2])
             } @$notValidFiles;

        my $inValidFiles     = $selectedFiles->[5] || [];
        my @inValidFileNames;
        map {
                &printLog(4,"  INVALID $_->[2]\n");
                push(@inValidFileNames, $_->[2])
            } @$inValidFiles;





        my $validC   = scalar(@$validFiles);
        my $nValidC  = scalar(@$notValidFiles);
        my $inValidC = scalar(@$inValidFiles);
        my $totalC   = $validC + $nValidC + $inValidC;
        my $tLeng    = length($totalC);

        &printLog(3,sprintf("  %0".$tLeng."d TOTAL FILES\n"    , $totalC  ));
        &printLog(3,sprintf("  %0".$tLeng."d VALID FILES\n"    , $validC  ));
        &printLog(3,sprintf("  %0".$tLeng."d NOT VALID FILES\n", $nValidC ));
        &printLog(3,sprintf("  %0".$tLeng."d INVALID FILES\n"  , $inValidC));

        if ( $run )
        {
            &printLog(3,"$project :: RUNNING BACKUP\n");
            if ((defined $preRun) && (length($preRun) >= 3))
            {
                &printLog(2,"$project :: RUNNING PRERUN : $preRun\n");
                &printLog(2,    "#"x3    , "PRE RUN " ,"#"x3    , "\n");
                my $preRunOut = `$preRun`;
                &printLog(2,    "\"", $preRunOut , "\"\n");
                &printLog(2,"$project :: PRERUN RUNNED\n");
            }




            my @invalid;
            my @valid;
            push(@valid,   @validFileNames)   if (@validFileNames);
            push(@invalid, @inValidFileNames) if (@inValidFileNames);

            if (( $addUnknown ) && (@notValidFileNames))
            {
                push(@valid,   @notValidFileNames);
            } else {
                push(@invalid, @notValidFileNames);
            }


            if ($autoClean)
            {
                &printLog(2,"$project :: CLEANING OLD\n");
                &cleanOld($baseFolder, $project, $autoClean);
                &printLog(2,"$project :: OLD CLEANED\n");
            }


            &printLog(2,"$project :: EXPORTING FILE\n");
            &createArchive($baseFolder, $project, $stpOut, \@invalid, \@valid, \@{$func->{exclude}{folder}});
            &printLog(2,"$project :: FILE EXPORTED\n");


            if ((defined $posRun) && (length($posRun) >= 3))
            {
                &printLog(2,"$project :: EXECUTING POSRUN : $posRun\n");
                &printLog(2,    "#"x3    , "POS RUN " , "#"x3 , "\n");
                my $posRunOut = `$posRun`;
                &printLog(2,    "\"", $posRunOut , "\"\n");
                &printLog(2,"$project :: POSRUN EXECUTED\n");
            }
        }

        if ((defined $posExec) && (length($posExec) >= 3))
        {
            &printLog(2,"$project :: EXECUTING POSEXEC : $posExec\n");
            &printLog(2,    "#"x3     , "POS EXEC " ,"#"x3, "\n");
            my $posExecOut = `$posExec`;
            &printLog(2,    "\"", $posExecOut, "\"\n" );
            &printLog(2,"$project :: POSEXEC EXECUTED\n");
        }

        &printLog(1,"$project :: PACKING FILES\n");
        &printLog(4,"$project :: COMPRESSING ", `tar --overwrite -czf $outputFolder/$project\_$timeStamp.tgz $outputFolder/$project\_$timeStamp.{log,lst,cln} 2>&1`,"\n");  #gz
#       &printLog(4,"$project :: COMPRESSING ", `tar --overwrite -cJf $outputFolder/$project\_$timeStamp.txz $outputFolder/$project\_$timeStamp.{log,lst,cln} 2>&1`,"\n");  #xz
#       &printLog(4,"$project :: COMPRESSING ", `tar --overwrite -cjf $outputFolder/$project\_$timeStamp.tbz2 $outputFolder/$project\_$timeStamp.{log,lst,cln} 2>&1`,"\n"); #bz2
        #&printLog(6,"$project :: BZIP ", `bzip2 -zf $outputFolder/$project*.{log,lst,cln} 2>/dev/null`,"\n");
        #&printLog(6,"$project :: BZIP ", `bzip2 -f $outputFolder/$project*.lst 2>/dev/null`,"\n");
        #&printLog(6,"$project :: BZIP ", `bzip2 -f $outputFolder/$project*.cln 2>/dev/null`,"\n");
        &printLog(1,"$project :: FILES PACKED\n");
        &printLog(4,"$project :: DELETING ", `rm -f $outputFolder/$project\_$timeStamp.{log,lst,cln} 2>&1`,"\n");


        &printLog(1,"$project :: PROJECT COMPLETED IN ",(time - $projectST),"s\n\n\n");
    }
}

&printLog(1,"END TIME :: $startTime : [",(time - $startTimeS),"s]\n");

close PROJLOG;
`tar --overwrite -czf $projLogFile.tgz $projLogFile 2>/dev/null`;
unlink($projLogFile);
print "CHANGING OWNERSHIP: " . `chown -R $defaultUser $bin/*` . "\n";

exit 0;






######################
######################
## FUNCTIONS
######################
######################

sub printLog
{
    my $v    = $_[0];
    my $line = join("",@_[1 .. (scalar(@_)-1)]);
    if ($verbose >= $v)
    {
        print "  "x($v+1), $line;
    }
    if ($v <= ($verbose+1))
    {
        print PROJLOG "  "x($v+1), $line;
    }
}

sub cleanOld
{
    my $folder       = $_[0];
    my $name         = $_[1];
    my $clean        = $_[2];
    my $rdiffClean   = "rdiff-backup  -v 3 --force --remove-older-than ".$clean."W \"$outputFolder/$name\" 2>&1";
    my $logFile      = "$outputFolder/$name\_$timeStamp.cln";

    if ( ! open LOG, ">$logFile")
    {
        &printLog(0,"COULD NOT OPEN LOG FILE :: $logFile : $!");
        die;
    }

        print LOG <<LOGTXT
### SETUP ###
FOLDER=$folder
NAME=$name
DATE=$timeStamp
### COMMAND ###
$rdiffClean
### OUTPUT ###
LOGTXT
;

    if ( -d "$outputFolder/$name" )
    {
        my $sleepCount = 0;
        while (`pgrep rdiff`)
        {
            sleep 5;
            $sleepCount++;
            if (($sleepCount+5) > $sleepGraceTime)
            {
                print LOG "SLEPT TOO LONG: > $sleepGraceTime\n";
                &printLog(0,"SLEPT TOO LONG: > $sleepGraceTime\n");
                die;
            }
        }

        my ($listLog, $bkpOut, $bkps) = &listBkps($name);
        if ( $bkps == -1 )
        {
            print LOG "NUMBER OF RDIFF BACKUPS: $bkps\n";
            print LOG "OUTPUT:\n $bkpOut\n";
            print LOG "ERROR DESCRIPTION: \n$listLog\n";

            &printLog(1,"NUMBER OF RDIFF BACKUPS: $bkps\n");
            &printLog(1,"OUTPUT:\n $bkpOut\n");
            &printLog(1,"ERROR DESCRIPTION: \n$listLog\n");
        }
        elsif ( $bkps == 0 )
        {
            print LOG "NUMBER OF RDIFF BACKUPS: $bkps\n";
            print LOG "OUTPUT:\n $bkpOut\n";
            print LOG "ERROR DESCRIPTION: \n$listLog\n";

            &printLog(1,"NUMBER OF RDIFF BACKUPS: $bkps\n");
            &printLog(3,"OUTPUT:\n $bkpOut\n");
            &printLog(1,"ERROR DESCRIPTION: \n$listLog\n");
        }
        elsif ( $bkps > 3 )
        {
            print LOG "NUMBER OF RDIFF BACKUPS: $bkps\n";
            print LOG "OUTPUT:\n $bkpOut\n";
            print LOG "RUNNING COMMAND: $rdiffClean\n";
            &printLog(2,"NUMBER OF RDIFF BACKUPS: $bkps\n");
            &printLog(3,"OUTPUT:\n $bkpOut\n");
            &printLog(3,"RUNNING COMMAND: $rdiffClean\n");

            if ($enableRdiff)
            {
                if (open (RDIFF, '-|', "$rdiffClean"))
                {
                    while (<RDIFF>)
                    {
                        &printLog(1, $_);
                        print LOG $_;
                    }

                    close RDIFF;
                } else {
                    &printLog(0,"COULD NOT OPEN PIPE : $!");
                    print LOG "COULD NOT OPEN PIPE : $!";
                    die;
                }
            } else {
                &printLog(0,"SKIPPING RDIFF EXECUTION DUE TO OVERRIDE");
                print LOG "SKIPPING RDIFF EXECUTION DUE TO OVERRIDE";
            }

            print LOG   "COMMAND EXECUTED\n\n";
            &printLog(3,"COMMAND EXECUTED\n\n");
        } else { # END ELSIF BKP > 3
            print LOG   "NUMBER OF LOG BACKUPS: $bkps\n";
            print       "NUMBER OF LOG BACKUPS: $bkps\n";
            print LOG   "OUTPUT:\n $bkpOut\n";
            print       "OUTPUT:\n $bkpOut\n";
            &printLog(2,"NUMBER OF LOG BACKUPS: $bkps\n");
            &printLog(3,"OUTPUT:\n $bkpOut\n");
        }# end if $bkp > 3
    } else { #END IF FOLDER EXISTS
        print LOG   "FOLDER $outputFolder/$name NOT FOUND. 1ST RUN?\n\n";
        print       "FOLDER $outputFolder/$name NOT FOUND. 1ST RUN?\n\n";
        &printLog(3,"FOLDER $outputFolder/$name NOT FOUND. 1ST RUN?\n\n");
    }

    print LOG   "DELETING OLD FILES :: OLDER THEN $clean WEEKS\n";
    print       "DELETING OLD FILES :: OLDER THEN $clean WEEKS\n";
    &printLog(3,"DELETING OLD FILES :: OLDER THEN $clean WEEKS\n");

    my $fls  = &listLog($name);
    print LOG   "DELETING OLD FILES :: ", (scalar keys %$fls) ," TOTAL FILES RETRIEVED\n";
    print       "DELETING OLD FILES :: ", (scalar keys %$fls) ," TOTAL FILES RETRIEVED\n";
    &printLog(2,"DELETING OLD FILES :: ", (scalar keys %$fls) ," TOTAL FILES RETRIEVED\n");

    foreach my $file (sort keys %$fls)
    {
        my $nfo    = $fls->{$file};

        my $year   = $nfo->{year};
        my $month  = $nfo->{month};
        my $day    = $nfo->{day};
        my $name   = $nfo->{name};
        my $path   = $nfo->{path};
        my $suffix = $nfo->{suffix};

        #print "FILE $file\n";
        #map { print "\t", uc($_), " = ", $nfo->{$_}, "\n"; } sort keys %$nfo;

        my $fileTime = timelocal(0,0,0,$day,$month-1,($year-1900));
        my $sysTime  = timelocal(0,0,0,$gMday,$gMon-1,($gYear-1900));
        my $dDiffSec = $sysTime - $fileTime;

        my $dDiffWee = (($dDiffSec / 3600) / 24) / 7;

        print LOG   "DELETING OLD FILES :: FILE TIME $fileTime SYSTIME $sysTime DIFF $dDiffSec / $dDiffWee\n";
        print       "DELETING OLD FILES :: FILE TIME $fileTime SYSTIME $sysTime DIFF $dDiffSec / $dDiffWee\n";
        &printLog(5,"DELETING OLD FILES :: FILE TIME $fileTime SYSTIME $sysTime DIFF $dDiffSec / $dDiffWee\n");

        print "FILE TIME $fileTime SYSTIME $sysTime DIFF $dDiffSec / $dDiffWee\n";
        print "DIFF TIME = $dDiffWee weeks\n\n";

        if ($dDiffWee > $clean)
        {
            my $full = $path."/".$file;
            print       "FOUND FILE: $file\n";
            print LOG   "FOUND FILE: $file\n";
            &printLog(4,"FOUND FILE: $file\n");
            print       "\tage -> $dDiffWee weeks\n";
            print LOG   "\tage -> $dDiffWee weeks\n";
            &printLog(4,"\tage -> $dDiffWee weeks\n");
            print       "\tfull -> $full\n";
            print LOG   "\tfull -> $full\n";
            &printLog(4,"\tfull -> $full\n");

            #map { print "\t$_ -> $nfo->{$_}\n"; } sort keys %$nfo;
            unlink($full);
        } # end if diff > clean
    } # end foreach my file

    print LOG   "COMMAND EXECUTED\n\n";
    print       "COMMAND EXECUTED\n\n";
    &printLog(3,"COMMAND EXECUTED\n\n");

    print LOG "\nEOF\n";
    close LOG;

}

sub listBkps
{
    my $name = $_[0];
    my $log;
    my $folder = $outputFolder . "/" . $name;

    $log  = "LISTING BACKUPS :: $name\n";
    $log .= "\tFOLDER $folder\n";
    &printLog(3,"LISTING BACKUPS :: $name\n");
    &printLog(3,"\tFOLDER $folder\n");

    if ( ! -d $folder )
    {
        my $err = "LISTING BACKUPS :: FOLDER $folder NOT FOUND\n";
        &printLog(0,$err);
        $log .= $err;
        return ($log, "", -1);
    };

    my $output = `rdiff-backup --list-increment-sizes $folder`;
    $log .= "\tOUTPUT\n$output\n";
    &printLog(4,"\tOUTPUT\n$output\n");

    if (index($output, "Fatal Error") != -1)
    {
        my $err = "LISTING BACKUPS :: RDIFF FATAL ERROR:\n $output\n";
        &printLog(1,$err);
        $log .= $err;
        return ($log, "", -1);
    };

    my @lines  = split(/\n/, $output);

    my $bkps   = 0;
    my %bytesFactor = (
        'bytes' => 1,
        'KB'    => 1024,
        'MB'    => 1024*1024,
        'GB'    => 1024*1024*1024,
    );


    my $err;
    for (my $l = 2; $l < @lines; $l++)
    {
        my $line  = $lines[$l];
        next if $line =~ /-{10}/;
        next if $line =~ /Cumulative size/;
        #                Tue   Jul   20    21 : 26 : 33     2010   2.44    MB      202     MB   (current mirror)
        #                Thu   Sep   9     20 : 02 : 27     2010   2.44    GB      2.44    GB   (current mirror)
        if ( $line =~ /(\w+\s+\w+\s+\d+\s+\d+\:\d+\:\d+)\s+\d+\s+(\S+)\s+(\w+)\s+(\S+)\s+(\w+)/ )
        #                1                                         2       3       4       5
        {
            my $time   = $1;
            my $size   = $2;
            my $sizeU  = $3;
            my $cSize  = $4;
            my $cSizeU = $5;
            my $curr   = $line =~ /\(current mirror\)/;

            if ( ( $curr ) && ( $cSize eq '' )  ) { $err .= "LISTING BACKUPS :: CUMMULATIVE SIZE IS ZERO : $cSize";  };
            if ( ! exists $bytesFactor{$sizeU}  ) { $err .= "LISTING BACKUPS :: ERROR CONVERTING UNITIES : $sizeU\n";  };
            if ( ! exists $bytesFactor{$cSizeU} ) { $err .= "LISTING BACKUPS :: ERROR CONVERTING C UNITIES : $cSizeU\n"; };

            my $sizeCo  = $size  * $bytesFactor{$sizeU};
            my $cSizeCo = $cSize * $bytesFactor{$cSizeU};
            if ( ( $size ) && ($sizeCo >= .6*$cSizeCo)){ $bkps++ };
            &printLog(5,"TIME: '$time' SIZE: '$sizeCo' ['$size', '$sizeU'] CUM SIZE: '$cSizeCo' ['$cSize', '$cSizeU'] CURRENT: '$curr'\n");
        } else {
            &printLog(0, "ERROR PARSING RDIFF LIST SIZES:\n $line\n");
            print "ERROR PARSING RDIFF LIST SIZES:\n $line\n";
            die;
        }
    }

    if ( defined $err )
    {
        &printLog(1,$err);
        &printLog(1,$output);
        $log .= $err;
        $log .= $output;
        return ($log, $output, 0);
    }

    $log .= "\tBACK UPs: $bkps\n";
    &printLog(3,"\tBACK UPs: $bkps\n");

    return ($log, $output, $bkps);

            #rdiff-backup --list-increment-sizes $1
            #-l, --list-increments
            #              List the number and date of partial incremental backups contained in the specified destination directory.  No backup or restore will take place if this option is given.
            #
            #       --list-increment-sizes
            #              List the total size of all the increment and mirror files by time.  This may be helpful in deciding how many increments to keep, and when to --remove-older-than.   Specify-
            #              ing a subdirectory is allowable; then only the sizes of the mirror and increments pertaining to that subdirectory will be listed.


            # ./rdiffList.sh desktop
            #        Time                       Size        Cumulative size
            #-----------------------------------------------------------------------------
            #Tue Jul 20 21:26:33 2010          202 MB            202 MB   (current mirror)
            #[root@SRV-FUNGI bkp_latest]# ./rdiffList.sh desktop
            #        Time                       Size        Cumulative size
            #-----------------------------------------------------------------------------
            #Tue Jul 20 21:30:21 2010         5.51 GB           5.51 GB   (current mirror)
            #Tue Jul 20 00:14:35 2010         0 bytes           5.51 GB
            #Thu Jul 15 00:03:21 2010         0 bytes           5.51 GB

            #./rdiffList.sh cgh
            #        Time                       Size        Cumulative size
            #-----------------------------------------------------------------------------
            #Tue Jul 20 21:26:33 2010          202 MB            202 MB   (current mirror)

            #./rdiffList.sh lost+found/
            #Fatal Error: Bad directory lost+found.
            #It doesn't appear to be an rdiff-backup destination dir

}



sub listLog
{
    my $name = $_[0];

    my $error = 0;
    opendir(DH, $outputFolder) or $error = 1;
    #print " OPENING DIR: $outputFolder for $name\n";
    if ($error)
    {
        &printLog(0, "\tCOULD NOT OPEN DIR $outputFolder\n");
        die;
    }

    my $startList   = time;
    my %fls;
    while (my $igot = readdir(DH))
    {
        #print "igot $igot\n";
        next if ($igot =~ /^\.{1,2}$/);
        next if ($igot !~ /$name/);
        next if ! -f "$outputFolder/$igot";

        my $year;
        my $month;
        my $day;

        next if ( $igot !~ /\.tgz$/ );
        #print "igot $igot VALID\n";
        if ($igot =~ /$name\_(\d+)\_(\d+)\_(\d+)/)
        {
            $year  = $1;
            $month = $2;
            $day   = $3;
            print "NAME $name FILE $igot HAS YEAR $year MONTH $month DAY $day\n";
        } else {
            print "NAME $name FILE $igot HAS WRONG FORMAT\n";
            #next;
            &printLog(0, "\tPROJECT $name FILE $igot HAS WRONG FORMAT\n");
            die;
        }
        &printLog(9, "\t",$igot,"\n");

        my ($name, $path, $suffix) = fileparse($igot, qr/\.[^.]*/);

        #print "igot $igot NAME $name PATH $path SUF $suffix\n";
        #push(@fls, $outputFolder.$igot);
        $fls{$igot}{year}   = $year;
        $fls{$igot}{month}  = $month;
        $fls{$igot}{day}    = $day;
        $fls{$igot}{name}   = $name;
        $fls{$igot}{path}   = $outputFolder;
        $fls{$igot}{suffix} = $suffix;

        if ((time - $startList) > ($sleepGraceTime*2))
        {
            &printLog(0, "\tLISTING FILE TOOK TOO LONG: >",($sleepGraceTime*2),"\n");
            die;
        }
    }
    closedir DH;

    return \%fls;
}

sub createArchive
{
    my $folder       = $_[0];
    my $name         = $_[1];
    my $stpOut       = $_[2];
    my $excFileNames = $_[3];
    my $incFileNames = $_[4];
    my $excFolders   = $_[5];

    my $incFiles      = join("\n",@$incFileNames);
    my $excFiles      = join("\n",@$excFileNames);
    my $excFoldersStr = '';
    map { $excFoldersStr .= " --exclude=$folder/$_"; } @$excFolders;

    my $logFile    = "$outputFolder/$name\_$timeStamp.log";
    my $lstFile    = "$outputFolder/$name\_$timeStamp.lst";
    my $rdiff      = "rdiff-backup  -v 3 --no-acls --exclude-filelist $lstFile --print-statistics $excFoldersStr \"$folder\" \"$outputFolder/$name\" 2>&1";

    my $incFileCount = scalar(@$incFileNames);
    my $excFileCount = scalar(@$excFileNames);
    &printLog(3,"OPENNING PROJECT LOG FILE :: $logFile\n");

    if ( ! open LOG, ">$logFile")
    {
        &printLog(0,"COULD NOT OPEN LOG FILE :: $logFile : $!");
        die;
    }

    print LOG <<LOGTXT
### SETUP ###
FOLDER=$folder
NAME=$name
DATE=$timeStamp
FILES INCLUDED=$incFileCount
FILES EXCLUDED=$excFileCount
$stpOut
### INCLUDE ###
$incFiles
### EXCLUDE ###
$excFiles
### COMMAND ###
$rdiff
### STATISTICS ###
LOGTXT
;

    &printLog(3,"OPENNING PROJECT LIST FILE :: $lstFile\n");
    if ( ! open LST, ">$lstFile") { &printLog(0,"COULD NOT OPEN LST FILE :: $lstFile : $!"); die; };
    print LST $excFiles;
    close LST;

    my $sleepCount = 0;
    while (`pgrep rdiff`)
    {
        sleep 5;
        $sleepCount++;
        die "SLEPT TOO LONG" if $sleepCount > $sleepGraceTime;
    }

    &printLog(3,"RUNNING COMMAND: $rdiff\n");
    print LOG "RUNNING COMMAND: $rdiff\n";
    if ($enableRdiff)
    {
        if (open (RDIFF, '-|', "$rdiff"))
        {
            while (<RDIFF>)
            {
                &printLog(1, $_);
                print LOG $_;
            }

            close RDIFF;
        } else {
            &printLog(0,"COULD NOT OPEN PIPE : $!");
            print LOG "COULD NOT OPEN PIPE : $!";
            die;
        }
    }



    my $rdiff2   = "rdiff-backup --list-increment-sizes \"$outputFolder/$name\" 2>&1";

    print LOG "COMMAND EXECUTED\n\n";
    &printLog(3,"COMMAND EXECUTED\n\n");
    print LOG "### HISTORY ###\n";
    print LOG "$rdiff2\n";
    if ($enableRdiff)
    {
        print LOG `$rdiff2`;
    }
    print LOG "\nEOF\n";
    close LOG;


    #my @files   = sort (glob("bkp_$name*.tar"));
    #my $outName = "bkp_$name\_$timeStamp.tar";

    #foreach my $file (@files)
    #{
    #   print "PREVIOUS BACKUP EXISTS :: $file\n";
    #}

    #my $first = $files[0] || '';
    #my $last  = $files[@files-1] || '';
    #print "FIRST $first\n";
    #print "LAST  $last\n";

    #Archive::Tar->create_archive($outName,0,@$fileNames);
    #if ($last eq $outName)
    #{
    #   print "REPLACING $outName\n";
    #
    #} else {
    #   print "MAKING DIFF FILE BETWEEN FIRST AND NEW BACKUP\n";
    #   #print `diff -a --brief -H`;
    #}
}

sub filterFiles
{
    my $all        = $_[0];
    my $func       = $_[1];
    my $byFolder   = $_[2];
    my $baseFolder = $_[3];
    my @selected;

    foreach my $file (@$all)
    {
        my $name     = $file->[0];
        my $path     = $file->[1];
        my $fullPath = $file->[2];

        my ( $valid, $reason ) = &checkExclude($file, $func, $byFolder, $baseFolder);

        $file->[3] = $valid;
        $file->[4] = $reason;

        if ( defined $valid )
        {
            push(@{$selected[$valid]}, $file);
            &printLog(6,"\t\tNAME     :: $name\n"    );
            &printLog(6,"\t\tPATH     :: $path\n"    );
            &printLog(6,"\t\tFULLPATH :: $fullPath\n");
            &printLog(6,"\t\tVALID    :: $valid\n"   );
            &printLog(6,"\t\tREASON   :: $reason\n\n");
        }
        else
        {
            push(@{$selected[5]}, $file);
            &printLog(7,"\t\tNAME     :: $name\n"    );
            &printLog(7,"\t\tPATH     :: $path\n"    );
            &printLog(7,"\t\tFULLPATH :: $fullPath\n");
            &printLog(7,"\t\tVALID    :: undef\n"   );
            &printLog(7,"\t\tREASON   :: $reason\n\n");
        }
    }

    return \@selected;
}

sub checkExclude
{
    my $file       = $_[0];
    my $func       = $_[1];
    my $byFolder   = $_[2];
    my $baseFolder = $_[3];

    my $name       = $file->[0];
    my $path       = $file->[1];
    my $fullPath   = $file->[2];

    my $reason     = 'NO REASON';
    my $valid      = 0;
    my $changed    = 0;

    #### EXCLUSION ####
    foreach my $excFolder ( @{$func->{exclude}{folder}} )
    {
        #print $excFolder, "\n";
        if (index($path, "$baseFolder/$excFolder") != -1)
        {
            $valid  = undef;
            $reason = "FAILED EXCLUDED PATH \"$excFolder\"";
            $changed++;
        }
    }


    foreach my $excExt ( @{$func->{exclude}{ext}} )
    {
        my $rindex = rindex($name, $excExt);
        if (( $rindex != -1) && ( $rindex == (length($name) - length($excExt))))
        {
            $valid  = undef;
            $reason = "FAILED EXCLUDED EXT \"$excExt\"";
            $changed++;
        }
    }




    #### INCLUSION ####
    foreach my $incFolder ( @{$func->{'include'}{folder}} )
    {
        if (index($path, "$baseFolder/$incFolder") != -1)
        {
            $reason .= " :: RECOVERED PATH \"$incFolder\"";
            $changed++;
            $valid = 1;
        }
    }


    foreach my $incExt ( @{$func->{'include'}{ext}} )
    {
        #print "CHECKING EXT: $incExt\n";
        my $rindex = rindex($name, $incExt);
        if (( $rindex != -1) && ( $rindex == (length($name) - length($incExt))))
        {
            $reason .= " :: RECOVERED EXT \"$incExt\"";
            $changed++;
            $valid = 1;
        }
    }



    ### BY FOLDER ###
    #$byFolder{$folder}{$function}{$objType}[$countF] = $value if ($value ne '');
    foreach my $folder ( keys %$byFolder )
    {
        if (index($path, "$baseFolder/$folder") != -1)
        {
            foreach my $function ( keys %{$byFolder->{$folder}})
            {
                foreach my $objType ( keys %{$byFolder->{$folder}{$function}} )
                {
                    foreach my $obj ( @{$byFolder->{$folder}{$function}{$objType}} )
                    {
                        if ($objType eq "ext")
                        {
                            my $rindex = rindex($name, $obj);
                            if (( $rindex != -1) && ( $rindex == (length($name) - length($obj))))
                            {
                                if ( $function eq "exclude" )
                                {
                                    $valid  = undef;
                                    $reason .= " :: FAILED EXCLUDED EXT \"$obj\" ON FOLDER \"$folder\"";
                                }
                                elsif ( $function eq "include" )
                                {
                                    $reason .= " :: RECOVERED EXT \"$obj\" ON FOLDER \"$folder\"";
                                    $valid   = 1;
                                }
                                $changed++;
                            }
                        }
                        elsif ($objType eq "folder")
                        {
                            if (index($path, "$baseFolder/$folder/$obj") != -1)
                            {
                                if ($function eq "exclude")
                                {
                                    $valid  = undef;
                                    $reason .= " :: FAILED EXCLUDED PATH \"$obj\" ON FOLDER \"$folder\"";
                                }
                                elsif ($function eq "include")
                                {
                                    $reason .= " :: RECOVERED PATH \"$obj\" ON FOLDER \"$folder\"";
                                    $valid = 1;
                                }
                                $changed++;
                            }
                        }
                    }
                }
            }
        }
    }

    if ($changed)
    {
        &printLog(8,"\t\tNAME     :: $name\n");
        &printLog(8,"\t\tPATH     :: $path\n");
        &printLog(8,"\t\tFULLPATH :: $fullPath\n");
        &printLog(8,"\t\tVALID    :: ", ($valid || 'undef'), "\n");
        &printLog(8,"\t\tREASON   :: $reason\n\n");
    }
    return ($valid, $reason);
}

sub loadSetup
{
    my $nfo        = $_[0];
    my $baseFolder = $nfo->{baseFolder};
    my %byFolder;
    my %func;

    if (substr($baseFolder, -1) eq "/") { chop $baseFolder; };

    foreach my $info (sort keys %$nfo)
    {
        my $value    = $nfo->{$info};
        if (substr($value,0,1) eq "/") { $value = substr($value, 1) };
        if (substr($value,-1)  eq "/") { chop($value)               };

        if ($info =~ /^(byFolder)\.\1(\d+).(include|exclude)\.(ext|folder)\.\4(\d+)/i)
        {
            my $prefix   = $1;
            my $count    = $2;
            my $function = $3;
            my $objType  = $4;
            my $countF   = $5;
            my $folder   = $nfo->{"$prefix\.$prefix$count\.folder"};

            &printLog(5, "PREFIX $prefix COUNT $count FUNC $function OBJTYPE $objType COUNT $countF FOLDER ",$folder," VALUE ",$value,"\n");
            $byFolder{$folder}{$function}{$objType}[$countF] = $value if ($value ne '');
        }
        elsif (($info =~ /^(include|exclude)\.(ext|folder)\.\2(\d+)/i))
        {
            my $prefix   = $1;
            my $function = $2;
            my $countF   = $3;

            &printLog(5, "PREFIX $prefix FUNC $function COUNT $countF VALUE $value\n");
            $func{$prefix}{$function}[$countF] = $value if ($value ne '');
        }
    }

    return ($baseFolder, \%func, \%byFolder);
}


sub listAll
{
    my $rootFolder = $_[0];
    my $folder     = $_[1];
    my $exclude    = $_[2];

    my %exclude;

    map {
        my $eFolder = $_;
        #print "IGNORE FOLDER $eFolder\n";
        #if (substr($eFolder, -1) ne "/")
        #{
        #   $eFolder .= "/";
        #}
        $exclude{$rootFolder."/".$eFolder} = 1;
    } @$exclude;

    #append a trailing / if it's not there
    $folder .= '/' if (substr($folder, -1) ne '/');
    &printLog(8, $folder, "\n");
    my $files = [];

    my @fls;
    my $error = 0;
    opendir(DH, $folder) or $error = 1;
    if ($error)
    {
        &printLog(0, "\tCOULD NOT OPEN DIR $folder\n");
        die;
    }

    my $startList   = time;
    while (my $igot = readdir(DH)) {
        next if ($igot =~ /^\.{1,2}$/);
        #print "igot $igot\n";
        push(@fls, $folder.$igot);
        if ((time - $startList) > ($sleepGraceTime*2))
        {
            &printLog(0, "\tLISTING FILE TOOK TOO LONG: >",($sleepGraceTime*2),"\n");
            die;
        }
    }
    closedir DH;

    #for my $eachFile (glob($folder.'*'))
    for my $eachFile (@fls)
    {
        #print "EACHFILE $eachFile\n";
        if ( -d $eachFile )
        {
            #if ($exclude{$eachFile}) { &printLog(3,"SKIPED $eachFile SUCCESSIFULLY\n"); next; };
            push(@$files, @{&listAll($rootFolder, $eachFile, $exclude)});
        } else {
            &printLog(9, "\t",$eachFile,"\n");
            my ($name, $path, $suffix) = fileparse($eachFile, qr/\.[^.]*/);
            my $file;
            $file->[0] = $name.$suffix;     # file Name
            $file->[1] = $path;     # file Path
            #$file->[2] = $suffix;   # suffix
            $file->[2] = $eachFile; # full Path
            push(@$files, $file);
        }
    }

    return $files;
}

sub listFiles
{
    my $inFolder = $_[0];
    my $ext      = $_[1];

    my $error = 0;
    opendir(DH, $inFolder) or $error = 1;

    if ($error)
    {
        &printLog(0, "\tCOULD NOT OPEN DIR $inFolder\n");
        die;
    }

    my $startList   = time;
    my @fls;
    while (my $igot = readdir(DH)) {
        next if ($igot =~ /^\.{1,2}$/);
        next if ( ! ( $igot =~ /$ext$/ ));
        #print "igot $igot\n";
        push(@fls, $inFolder."/".$igot);
    }
    closedir DH;

    @fls = sort @fls;

    return \@fls;
}

1;