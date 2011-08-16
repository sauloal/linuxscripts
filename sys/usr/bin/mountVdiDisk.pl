#!/usr/bin/perl -w
# 2010 08 10 - 1750
# Saulo Aflitos
# Based on http://wiki.przemoc.net/tips/linux#mounting_partition_from_vdi_fixed-size_image
# License: GPL
use strict;

my $inFile   = $ARGV[0];

if ( ! defined $inFile )    { die "FILE NOTE DEFINED" };
if ( ! -f      $inFile )    { die "FILE $inFile DOES NOT EXISTS" };

# EXTRACT FILE NAME WITHOUT EXTENSION
my $folderName = substr($inFile    , 0, rindex($inFile, "."));
   $folderName = substr($folderName, (rindex($folderName, "/") || 0 ) + 1);
print "INFILE $inFile\n";
print "OUT    $folderName\n";
if ( ! defined $folderName ) { die "COULD NOT EXTRACT NAME FROM FILE. $folderName"};


# EXTRACT BOOT SECTOR OFFSET DUE TO VDI HEADER
my $awk    = "od -j344 -N4 -td4 $inFile | awk 'NR==1{ print \$2; }'";
if ( ! defined $awk ) { die "FAILED CREATING AWK COMMAND" };
my $offSet = `$awk`;
if ( ! defined $offSet ) { die "COULD NOT EXTRACT OFFSET" };
chomp($offSet);
print "AWK     $awk\n";
print "OFFSET  $offSet\n";

# EXTRACT BOOT LOADER
my $dd          = "dd if=$inFile of=$folderName bs=1 skip=$offSet count=1b";
# EXTRACT PARTITION TABLE - VERBOSE
my $sfdisk      = "sfdisk -luS $folderName";
# EXTRACT PARTITION TABLE - EXCLUDE SWAP AND HEADERS
my $sfdiskValid = "sfdisk -luS $folderName | grep $folderName | grep -v Disk | grep -v swap";

print "DD      $dd\n";
print `$dd`, "\n";

print "SFDISK  $sfdisk\n";
print `$sfdisk`,"\n";

print "SFDISKV $sfdiskValid\n";
my @DISKDATA=`$sfdiskValid`;
print join("", @DISKDATA);
print "\n";
if ( ! @DISKDATA ) { die "NO DISK DATA EXTRACTED: ", @DISKDATA, "\n"; };

# DELETE TEMPORARY BOOT SECTOR FILE
unlink($folderName);

my $start  = 0; 
my @outs;
if ( @DISKDATA )
{
    foreach my $line ( @DISKDATA )
    {
        chomp $line;
        # DELETE * (BOOT)
        $line =~ s/\s+\*//;
        print "\tLINE $line\n";

        # fedora1   *      2048   1026047    1024000  83  Linux
        # fedora2       1026048   2074623    1048576  82  Linux swap / Solaris
        if ($line =~ /(\S+)\s+(\d+)\s+(\d+)\s+(\d+)/) 
        {
            if ( ! $start ) 
            {
                $start = $2; 
                print "\t\tNFO START  $start\n"; 
                print "\t\tNFO OFFSET $offSet\n";
            }

            my $name  = $1;
            my $begin = $2;
            my $val   = $offSet + ($begin * 512); 
            print "\t\tNFO START $start OFFSET $offSet NAME $name BEGIN $begin VAL $val\n";
            push(@outs, [$name, $val]); 
        }
    }
} else {
    my $name = $folderName . "1";
    my $val  = $offSet;
    print "\t\tNFO START $start OFFSET $offSet NAME $name BEGIN 0 VAL $val\n";
    push(@outs, [$name, $val]); 
}


die if ( ! @outs );
foreach my $pair ( @outs )
{
    my $name  = $pair->[0];
    my $off   = $pair->[1];
    my $mount = "mount $inFile $name -o loop,offset=$off";
    mkdir($name) if ( ! ( -d $name ) );
    print "\tMOUNT   $mount\n";
    print "\tMOUNT   losetup -f -o $off $inFile\n\n";

    # EXPORT COMMANDS 
    open MO,  ">$inFile.$name.mount";
    open UMO, ">$inFile.$name.umount";

    print MO  $mount, "\n";
    print MO  "#losetup -f -o $off $inFile\n";
    print UMO "umount $name\n";
    print UMO "#losetup -d $name\n";

    close MO;
    close UMO;

    `chmod +x $inFile.$name.mount`;
    `chmod +x $inFile.$name.umount`;
}

#print "losetup -f -o \$((512*3)) $inFile\n";

1;