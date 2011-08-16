#!/usr/bin/perl -w
use strict;
use warnings;

#################################
## CONFIG SESSION
## CHANGE PARAMETERS HERE
## AUTO BAKUP USING LRZIP
## S. AFLITOS 2008 OCT 17 13:04
## V.1.0
#################################
##
## TO DO:
## AUTOMATIC CALCULATE SPEED
## MAKE SIZE CALCULATION WORK
##      MOUNT EACH PARTITION TO BE ABLE TO USE DF
##      CHECK EACH PARTITION FOR PROBLEMS AND USE THE INFORMATION FROM FSDISK
## USE ARRAY TO STORE OUTPUT FROM DD AND LRZIP
##
## USE PERL DF LIBRARY (?)
## RUN 2 PROCESSES AT ONCE (?)
## 
#################################

my %devices_to_save = ( "/dev/sda1", "/boot",
            "/dev/sda3", "/",
            "/dev/sda5", "/usr",
            "/dev/sda6", "/var",
            "/dev/sda7", "/home",
            "/dev/sdb1", "/xp",
            "/dev/sdb2", "/xp_restore",);

my %bkp_device      = ( "/dev/sda8","BKP");

my $only_umounted   = 1; # only allows backup of umounted units (recommended)
my $real            = 1; # do run the programs or not

my $gzip_comp       = 1; # gzip compression level
my $mem_lrz     = 3; # mem alocated to lrz in hundred MB

# START TIME : 13:28
# END   TIME : 
# TOTAL TIME : 
# 2008 10 17
#-----------------------------------------------------------------------------------------------------------------------------------------------------------
#| folder | mount | size  | used  | speed   | sizeGZ | compGZ_Size | compGZ_Use | timeGZ   | sizeLRZ | timeLRZ  | compLRZ_Size  | compLRZ_Use | compLRZ_GZ |
#-----------------------------------------------------------------------------------------------------------------------------------------------------------
#| sda1   | /boot | 000.2 |       | 58.6m/s | XX.X   | 15.38       |            | 01min00s | 00.013  | 00min03s |  15.38 / x.xx |             | 1.026      |
#| sda3   | /     | 032   |       | 62.0m/s | 01.0   | 32.00       |            | 08min39s | 00.794  | 00min24s |  40.30 / 1.25 |             | 1.191      |
#| sda5   | /usr  | 107   |       | 32.8m/s | 08.8   | 12.16       |            | 54min36  | 04.100  | 02min59s |  26.09 / 1.05 |             | 2.146      |
#| sda6   | /var  | 107   |       | 48.9m/s | 02.4   | 44.58       |            | 36min00s | 02.200  | 01min09s |  48.64 / 1.09 |             | 1.114      |
#| sda7   | /home | 107   |       | 33.5m/s | 02.3   | 46.52       |            | 53min29s | 00.876  | 00min25s | 122.10 / 1.23 |             | 2.626      |
#| sdb1   | /xp   | 239   |       | 68.9m/s | 13.0   | 18.38       |            | 57min54s | 12.000  | 18min38s |  19.91 / 1.08 |             | 1.087      |
#| sdb2   | /xp_r | 011   |       | 27.3m/s | 08.0   | 2.375       |            | 06min34s | 03.800  | 03min04s |   2.89 / 1.03 |             | 2.768      |
#-----------------------------------------------------------------------------------------------------------------------------------------------------------
#                                                     size/gzsize    used/gzsize                                 size/lrzsize   used/lrzsize  gzsize/lrzsize 

#################################
## DECLARATION SESSION
#################################

my $gzip;
my $dd;
my $df;
my $fdisk;
my $lrzip;

my $compression_level = 0.44 * 1.5; # final avg compression rate
my $min_per_giga_bzip = 0.21 * 2; # relative to the HD size and gzip
my $min_per_giga_lzip = 0.22 * 2; # relative to the HD used space and lzip

my %target;         # devices to be saved
my %bkp_device_inf; # info about devices to be saved
my %process_inf;    # info about process

my @pi_code = (
"Number of HDs Found",                 "Number of Targets Configured",
"Number of Targets Found",             "Number of Backup Devices Configured",
"Number of Backup Devices Found",      "Total To Save",
"Total Expected Output Size",          "Free space in Bakup Device",
"Total Expected Process Time");



#################################
## RUN FLOW SESSION
#################################

&check_programs; # checks is necessary programs are instaled

my $time_stamp  = &time_stamp;

my @output      = &mem_analysis(\%devices_to_save,\%bkp_device);
%target         = %{$output[0]};
%bkp_device_inf = %{$output[1]};
%process_inf    = %{$output[2]};

&print_device(\%target,         "short", "DEVICES TO SAVE (from)");

&print_device(\%bkp_device_inf, "long", "DEVICE OF DESTINY (to)");

&check_mount(\%bkp_device_inf, \%target);

&check_safety(\%bkp_device, \%devices_to_save, \%process_inf); # checks for inconsistence in parameters

&print_process_info(\%process_inf);

&execute_backup(\%bkp_device_inf, \%target);





#################################
## FUNCTIONS SESSION
#################################



sub execute_backup
{
    my %bkp_device_inf = %{$_[0]};
    my %target         = %{$_[1]};

    my $bkp_device_dir   = (keys %bkp_device_inf)[0];
    my $bkp_device_mount = $bkp_device_inf{$bkp_device_dir}{"mount"};

    print "\n\n";
    print "BACKUP DEVICE DIR            $bkp_device_dir\n";
    print "BACKUP DEVICE MOUNTING POINT $bkp_device_mount\n\n";

    `mkdir $bkp_device_mount/$time_stamp 2>>/dev/null`;

    foreach my $device_dir (sort keys %target)
    {
        my $device_mount       = $target{$device_dir}{"mount"};

        if (( ! $device_mount) || ( $device_mount eq "-")) # checks if there's a mounting point, otherwise put the dir as mounting point to generate the short name
        {
            $device_mount = $device_dir;
        }

        my $device_mount_short = $device_mount;

        if ($device_mount_short eq "/")
        {
            $device_mount_short = "root";
        }
        else
        {
            if ($device_mount_short =~ /^\//)
            {
                $device_mount_short = $'; # '
                $device_mount_short =~ tr/\//_/;
            }
            else
            {
                 $device_mount_short =~ tr/\//_/;
            }
        }

        my $filename    = "$time_stamp\_$device_mount_short";
        my $filenameGZ  = "$bkp_device_mount/$time_stamp/$filename.gz";
        my $filenameLRZ = "$bkp_device_mount/$time_stamp/$filename.lrz";

        print "SAVING DEVICE DIR             $device_dir\n";
        print "SAVING DEVICE MOUNT POINT     $device_mount\n";
        print "SAVING DEVICE NAME            $device_mount_short\n";
        print "SAVING DEVICE SHORT FILE NAME $filename\n";
        print "SAVING DEVICE FULL  FILE NAME $filenameLRZ\n";

        my $r_gzip  = "time $dd if=$device_dir bs=4M conv=notrunc | $gzip -$gzip_comp > $filenameGZ";
        my $r_lrzip = "time $lrzip -L 9 -w $mem_lrz -n -D -o $filenameLRZ $filenameGZ";

        print "GZIP  COMMAND $r_gzip\n";
        print "LRZIP COMMAND $r_lrzip\n\n\n";


        if ( (! -f $filenameGZ ) && ( ! -f $filenameLRZ ))
        {
            if ($real)
            {
                print `time $r_gzip`;
            };
        }
        else
        {
            #die "\tERR 10: FILE $filenameGZ EXISTS\n\tPLEASE DELETE IT AND RUN AGAIN\n";
            print "\tWARNING: FILE $filenameGZ OR $filenameLRZ EXISTS\n\tIF THIS FILE IS NOT INTENDED TO BE USED\n\tDELETE IT AND RUN AGAIN\n\tSKIPPING THIS STEP\n\n";
        };
    
        if ( ! -f $filenameLRZ )
        {
            if ($real)
            {
                print `time $r_lrzip`;
            }
        }
        else
        {
            #die "\tERR 11: FILE $filenameLRZ EXISTS\n\tPLEASE DELETE IT AND RUN AGAIN\n";
            print "\tWARNING: FILE $filenameLRZ EXISTS\n\tIF THIS FILE IS NOT INTENDED TO BE USED\n\tDELETE IT AND RUN AGAIN\n\tSKIPPING THIS STEP\n\n";
        };
#       die;
    }

#   `time dd if=/dev/sda3 | gzip -1 > /media/BKP/root_gzip1.gz`;
#   `time lrzip -L 9 -w 3 -n -o /media/BKP/root_gzip1_lrzip9_N.lrz /media/BKP/root_gzip1.gz`;

}

sub time_stamp
{
    my ($sec,$min,$hour,$mday,$mon,$year, $wday,$yday,$isdst) = localtime time;
    $year += 1900;
    if ($mday < 10) { $mday = "0$mday"; };
    if ($mon  < 10) { $mon  = "0$mon" ; };

    my $time_stamp = "$year\_$mon\_$mday";
    return $time_stamp;
}

sub check_mount
{
    my %bkp_device_inf = %{$_[0]};
    my %target         = %{$_[1]};

    my @mount = `mount`;

    print "MOUNT CHECK\n";

    if ( ! @mount ) { die "\tERR 07: MOUNT RETURNED NOTHING\n"; };

    my $bkp_on     = 0;
    my $bkp_device = (keys %bkp_device_inf)[0];

    for (my $i = 0; $i < @mount; $i++)
    {
        my $line        = $mount[$i];
        my @pieces      = split(/\s+/,$line);
        my $dir         = $pieces[0];
        my $mount_point = $pieces[2];

        if ($only_umounted)
        {
            if ( exists $target{$dir} )
            {
                die "\tERR 08: DRIVE $dir MOUNTED\n\tIMPOSSIBLE TO BACKUP\n\tPLEASE UMOUNT IT FIRST\n";
            };
        }

        if ( $bkp_device eq $dir) { $bkp_on = 1; };
    }

    print "\tSOURCE DEVICES TO BACKUP (from) STATE.....all umounted\n";

    if ( ! $bkp_on ) { die "\tERR 09: DRIVE $bkp_device NOT MOUNTED\n\tIMPOSSIBLE TO BACKUP\n\tPLEASE MOUNT IT FIRST\n"; };
    print "\tDESTINATION DEVICE TO BACKUP (to) STATE...mounted\n";
    print "\n" . "-" x 40 . "\n";
}

sub check_programs
{
    print "DEPENDENCY CHECK\n";
    $gzip  = `locate --regex --limit 1 /gzip\$ 2>/dev/null`;  chomp($gzip);
    $dd    = `locate --regex --limit 1 /dd\$ 2>/dev/null`;    chomp($dd);
    $df    = `locate --regex --limit 1 /df\$ 2>/dev/null`;    chomp($df);
    $fdisk = `locate --regex --limit 1 /fdisk\$ 2>/dev/null`; chomp($fdisk);
    $lrzip = `locate --regex --limit 1 /lrzip\$ 2>/dev/null`; chomp($lrzip);

    if ( ( ! $lrzip ) && ( -f "./lrzip/lrzip" )) { $lrzip = "./lrzip/lrzip"; };
    my $fail  = 0;

    print "GZIP..."; if ($gzip)  { print "OK\t$gzip\n";  } else { print "FAIL\n"; $fail = 1; };
    print "LRZIP.."; if ($lrzip) { print "OK\t$lrzip\n"; } else { print "FAIL\n"; $fail = 1; };
    print "DD....."; if ($dd)    { print "OK\t$dd\n";    } else { print "FAIL\n"; $fail = 1; };
    print "DF....."; if ($df)    { print "OK\t$df\n";    } else { print "FAIL\n"; $fail = 1; };
    print "FDISK.."; if ($fdisk) { print "OK\t$fdisk\n"; } else { print "FAIL\n"; $fail = 1; };

    if ($fail) { die "\tERR00: ONE OF THE NECESSARY PROGRAMS WAS NOT FOUND\n"; };

    print "\n" . "-" x 40 . "\n";
#     | grep -v share | grep -v include | grep -v lib | grep bin
}


sub check_safety
{
    my %bkp_devic      = %{$_[0]};
    my %devices_to_sav = %{$_[1]};
    my %process_info   = %{$_[2]};

    my $count_targets        = $process_info{$pi_code[2]};
    my $count_bkp            = $process_info{$pi_code[3]};
    my $expected_output_size = $process_info{$pi_code[6]};
    my $target_free          = $process_info{$pi_code[7]};
    my $devices_to_save      = (keys %devices_to_sav);
    my $bkp_devices          = (keys %bkp_devic);

    print "SAFETY CHECK\n";

    if ( $count_targets < $devices_to_save)
    {
        print "\t$count_targets TARGETS FOUND WHERE\n";
        print "\t$devices_to_save WERE EXPECTED\tFAIL\n\n";
        die "\tERR 04: NOT ALL OF THE CONFIGURED TARGETS WERE FOUND\n\tIT SEEMS A MISCONFIGURATION PROBLEM\n\tOR YOUR DRIVE PATHS HAVE CHANGED\n\n";
    }
    else
    {
        print "\t$count_targets TARGETS FOUND WHERE\n";
        print "\t$devices_to_save WERE EXPECTED\tOK\n\n";
    }


    if ( $count_bkp     != $bkp_devices)
    {
        print "\t$count_bkp BACKUP DEVICES FOUND WHERE\n";
        print "\t$bkp_devices WERE EXPECTED\tFAIL\n\n";
        die "\tERR 05: BAKUP DRIVE NOT FOUND\n\tIT SEEMS A MISCONFIGURATION PROBLEM\n\tOR YOUR DRIVE PATHS HAVE CHANGED\n\n";
    }
    else
    {
        print "\t$count_bkp BACKUP DEVICES FOUND WHERE\n";
        print "\t$bkp_devices WERE EXPECTED\tOK\n\n";
    }


    if ( $expected_output_size >= $target_free)
    {
        print "\t$expected_output_size GB EXPECTED IN OUTPUT FILE AND\n";
        print "\t$target_free GB FREE IN BACKUP DISK\tFAIL\n\n";
        die "\tERR 06: NOT ENOUGHT SPACE TO SAVE THE BACKUP FILES\n\tTRY TO CLEAN UP THE BAKUP DRIVER\n\n";
    }
    else
    {
        print "\t$expected_output_size GB EXPECTED IN OUTPUT FILE AND\n";
        print "\t$target_free GB FREE IN BACKUP DISK\tOK\n\n";
    }

    print "-" x 40 . "\n";
}


sub mem_analysis
{
    my %dev_to_save = %{$_[0]};
    my %bkp_dev     = %{$_[1]};
    my @mem;#       = `$df -h`;
#   my @fdisk       = `$fdisk -l`;

    foreach my $dev (keys %dev_to_save)
    {
        my @answer = `$df $dev`;
#       print "$dev\t$answer[1]";
        if ( ! ($answer[1] =~ /^[\/|\-]/)) { die "\tERR 01: NO OUTPUT OBTAINED FROM DF\n\tCHECK IF THE PROGRAM IS INSTALLED IN YOUR SYSTEM\n\tOR IF $dev EXISTS\n\n"; };
        push @mem, "$dev\t$answer[1]";
    }

    foreach my $dev (keys %bkp_dev)
    {
        my @answer = `$df $dev`;
#       print "$dev\t$answer[1]";
        if ( ! ($answer[1] =~ /^[\/|\-]/)) { die "\tERR 11: NO OUTPUT OBTAINED FROM DF\n\tCHECK IF THE PROGRAM IS INSTALLED IN YOUR SYSTEM\n\tOR IF $dev EXISTS\n\n"; };
        push @mem, "$dev\t$answer[1]";
    }

    if ( ! @mem )   { die "\tERR 12: NO OUTPUT OBTAINED FROM DF\n\tCHECK IF THE PROGRAM IS INSTALLED IN YOUR SYSTEM\n\n"; };
#   if ( ! @fdisk ) { die "\tERR 13: NO OUTPUT OBTAINED FROM FDISK\n\tCHECK IF THE PROGRAM IS INSTALLED IN YOUR SYSTEM\n\n"; };

    my %targets;
    my %bkp_device_info;
    my %process_info;

    my $count_hd      = 0; # counts number of HDs found
    my $count_targets = 0; # counts number of HDs found that are in the target list
    my $total_to_save = 0; # counts total of GB to save
    my $total_hd      = 0; # total size of all HDs
    my $target_free   = 0; # total of free GB on BKP device
    my $count_bkp     = 0; # counts number of BKP devices; should be 1

    foreach my $line (sort @mem)
    {
        if ($line =~ /(\/\S+)\s+((\/\S+)|(\-))\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\%\s+(\/\S*)/ )
        {
            #       1       2(3       4)       5       6       7       8          9          
#           print $line;
            my $deviceUn = $1;
            my $deviceMo = $2;
            my $size     = $5;
            my $used     = $6;
            my $avail    = $7;
            my $use      = $8;

            my $mount;
            if (($4) && ($4 eq "-"))
            {
                $mount    = "-";
            }
            else
            {
                $mount    = $9;
            }

            my $size_num  = &convert_unit($size);
            my $used_num  = &convert_unit($used);
            my $avail_num = &convert_unit($avail);

            if (exists $devices_to_save{$deviceUn})
            {
#               print "$deviceUn\t$deviceMo\t$size\t($size_num G)\t$used\t($used_num G)\t$avail\t($avail_num G)\t$use %\t$mount\n";
                $targets{$deviceUn}{"size"}      = $size;
                $targets{$deviceUn}{"size_num"}  = $size_num;

                $targets{$deviceUn}{"used"}      = $used;
                $targets{$deviceUn}{"used_num"}  = $used_num;

                $targets{$deviceUn}{"avail"}     = $avail;
                $targets{$deviceUn}{"avail_num"} = $avail_num;

                $targets{$deviceUn}{"use"}       = $use;
                $targets{$deviceUn}{"mount"}     = $mount;
                $targets{$deviceUn}{"bkp_size"}  = sprintf("%.2f", $used_num * $compression_level);
                $total_to_save += $used_num;
                $total_hd      += $size_num;
                $count_targets++;
            }
            elsif (exists $bkp_device{$deviceUn})
            {
#               print "$deviceUn\t$deviceMo\t$size\t($size_num G)\t$used\t($used_num G)\t$avail\t($avail_num G)\t$use %\t$mount\n";
                $bkp_device_info{$deviceUn}{"size"}      = $size;
                $bkp_device_info{$deviceUn}{"size_num"}  = $size_num;

                $bkp_device_info{$deviceUn}{"used"}      = $used;
                $bkp_device_info{$deviceUn}{"used_num"}  = $used_num;

                $bkp_device_info{$deviceUn}{"avail"}     = $avail;
                $bkp_device_info{$deviceUn}{"avail_num"} = $avail_num;

                $bkp_device_info{$deviceUn}{"use"}       = $use;
                $bkp_device_info{$deviceUn}{"mount"}     = $mount;

                $target_free = $avail_num;
                $count_bkp++;
            }
                $count_hd++;
        }
    }

    my $expected_output_size = $total_to_save * 1.2 * $compression_level;
    my $expected_time        = ((($total_to_save * 1.02) * $min_per_giga_lzip) + (($total_hd * 1.02) * $min_per_giga_bzip));

    $process_info{$pi_code[0]} = $count_hd;
    $process_info{$pi_code[1]} = (keys %devices_to_save);
    $process_info{$pi_code[2]} = $count_targets;
    $process_info{$pi_code[3]} = $count_bkp;
    $process_info{$pi_code[4]} = (keys %bkp_device);
    $process_info{$pi_code[5]} = sprintf("%.2f", $total_to_save);
    $process_info{$pi_code[6]} = sprintf("%.2f", $expected_output_size);
    $process_info{$pi_code[7]} = sprintf("%.2f", $target_free);
    $process_info{$pi_code[8]} = sprintf("%.2f", $expected_time);

    if ( ! $count_hd ) { die "\tERR 03: NOT RECOGNIZABLE OUTPUT FROM DF\n\tSHOULD BE /DEV/SDAX XXN XXN XXN XX% NN\n\n"; };

    my @output;
    $output[0] = \%targets;
    $output[1] = \%bkp_device_info;
    $output[2] = \%process_info;
    return @output;
}





sub print_process_info
{
    my %process_info = %{$_[0]};

    print "PROCESS INFO\n";

    foreach my $key (sort keys %process_info)
    {
        my $value = $process_info{$key};

    my $temp = $~;
    $~ = "PRINT_PROCESS_INFO";
    format PRINT_PROCESS_INFO =
    ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ^>>>>>>
    $key,                                $value
.
    write;
    $~ = $temp;
    }
    print "\n" . "-" x 40 . "\n";
}


sub convert_unit
{
    # converts to Giga Bytes
    my $original = $_[0];
    my $result;

    if ($original =~ /([0-9]+)/)
    {
        my $num_orig = $1;
        my $num_unit = $3;
        $result = sprintf("%.2f", ($num_orig / (1024 * 1024)));
        #print "$size \t$size_num_orig\t$size_num_unit\t$size_num\n";
    }
    else
    {
        die "$original\n\tERR 02: NOT RECOGNIZABLE OUTPUT FROM DF\n\tUNIT SHOULD BE T G M OR K\n\n";
    }

    return $result;
}


sub print_device
{
    my %targets = %{$_[0]};
    my $format  = $_[1];
    my $title   = $_[2];

    print uc($title) . ":\n";

    if ($format eq "short")
    {
        foreach my $key (keys %targets)
        {
            print "\t" . $key . "(" . $targets{$key}{"mount"} . ")\n";
        }
    }
    elsif ($format eq "long")
    {
        foreach my $key (keys %targets)
        {
            print "$key\n";
            my $lines;
            foreach my $subk (sort keys %{$targets{$key}})
            {
    #           print "\t$subk\t" . $targets{$key}{$subk} . "\n";
                #$lines .= "\t$subk\t" . $targets{$key}{$subk} . "\n";
                my $subk_value = $targets{$key}{$subk};
    
                my $temp = $~;
                $~ = "PRINT_TARGETS";
                format PRINT_TARGETS =
        ^<<<<<<<<<< ^*
        $subk,      $subk_value
.
                write;
                $~ = $temp;
            }
        }
    }
    print "\n" . "-" x 40 . "\n";
}

1;



sub mem_analysis_2
{
    my @mem = `df -h`;

    if ( ! @mem ) { die "\tERR 01: NO OUTPUT OBTAINED FROM DF\n\tCHECK IF THE PROGRAM IS INSTALLED IN YOUR SYSTEM\n\n"; };

    my %targets;
    my %bkp_device_info;
    my %process_info;

    my $count_hd      = 0; # counts number of HDs found
    my $count_targets = 0; # counts number of HDs found that are in the target list
    my $total_to_save = 0; # counts total of GB to save
    my $total_hd      = 0; # total size of all HDs
    my $target_free   = 0; # total of free GB on BKP device
    my $count_bkp     = 0; # counts number of BKP devices; should be 1

    foreach my $line (@mem)
    {
        if ($line =~ /(\/\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/)
        {
            #print $line;
            my $device   = $1;
            my $size     = $2;
            my $used     = $3;
            my $avail    = $4;
            my $use      = $5;
            my $mount    = $6;

            my $size_num = &convert_unit($size);
            my $used_num = &convert_unit($used);

            if (exists $devices_to_save{$device})
            {
#               print "$device $size ($size_num) $used ($used_num) $avail $use $mount\n";
                $targets{$device}{"size"}     = $size;
                $targets{$device}{"size_num"} = $size_num;

                $targets{$device}{"used"}     = $used;
                $targets{$device}{"used_num"} = $used_num;

                $targets{$device}{"avail"}    = $avail;
                $targets{$device}{"use"}      = $use;
                $targets{$device}{"mount"}    = $mount;
                $targets{$device}{"bkp_size"} = sprintf("%.2f", $used_num * $compression_level);
                $total_to_save += $used_num;
                $total_hd      += $size_num;
                $count_targets++;
            }
            elsif (exists $bkp_device{$device})
            {
                $bkp_device_info{$device}{"size"}     = $size;
                $bkp_device_info{$device}{"size_num"} = $size_num;

                $bkp_device_info{$device}{"used"}     = $used;
                $bkp_device_info{$device}{"used_num"} = $used_num;

                my $avail_num = &convert_unit($avail);

                $bkp_device_info{$device}{"avail"}     = $avail;
                $bkp_device_info{$device}{"avail_num"} = $avail_num;
                $bkp_device_info{$device}{"use"}       = $use;
                $bkp_device_info{$device}{"mount"}     = $mount;

                $target_free = $avail_num;
                $count_bkp++;
            }
                $count_hd++;
        }
    }

    my $expected_output_size = $total_to_save * 1.2 * $compression_level;
    my $expected_time        = ((($total_to_save * 1.02) * $min_per_giga_lzip) + (($total_hd * 1.02) * $min_per_giga_bzip));

    $process_info{$pi_code[0]} = $count_hd;
    $process_info{$pi_code[1]} = (keys %devices_to_save);
    $process_info{$pi_code[2]} = $count_targets;
    $process_info{$pi_code[3]} = $count_bkp;
    $process_info{$pi_code[4]} = (keys %bkp_device);
    $process_info{$pi_code[5]} = sprintf("%.2f", $total_to_save);
    $process_info{$pi_code[6]} = sprintf("%.2f", $expected_output_size);
    $process_info{$pi_code[7]} = sprintf("%.2f", $target_free);
    $process_info{$pi_code[8]} = sprintf("%.2f", $expected_time);

    if ( ! $count_hd ) { die "\tERR 03: NOT RECOGNIZABLE OUTPUT FROM DF\n\tSHOULD BE /DEV/SDAX XXN XXN XXN XX% NN\n\n"; };

    my @output;
    $output[0] = \%targets;
    $output[1] = \%bkp_device_info;
    $output[2] = \%process_info;
    return @output;
}


sub convert_unit_2
{
    # converts form any unity to Giga Bytes
    my $original = $_[0];
    my $result;

    my %units = (   "T", "0.000976562",
            "G", "1",
            "M", "1024",
            "K", "1048576" );

    if ($original =~ /(([0-9]|\.)+)(T|G|M|K)/)
    {
        my $num_orig = $1;
        my $num_unit = $3;
        $result = sprintf("%.2f", ($num_orig / $units{$num_unit}));
        #print "$size \t$size_num_orig\t$size_num_unit\t$size_num\n";
    }
    else
    {
        die "$original\n\tERR 02: NOT RECOGNIZABLE OUTPUT FROM DF\n\tUNIT SHOULD BE T G M OR K\n\n";
    }

    return $result;
}