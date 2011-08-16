#!/usr/bin/perl -w
#Uses the linux command "last" to list all logins from all users in the machine.
#generates a report with how many hours each user spent logged (first login until last loggoff) in the system.
use strict;
my $verbose = 0; # 0 - 6


my @last = `last -R | grep -v crash | grep -v reboot`;
my @month = qw ( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
my %month = (   Jan => 0,
                Feb => 1,
                Mar => 2,
                Apr => 3,
                May => 4,
                Jun => 5,
                Jul => 6,
                Aug => 7,
                Sep => 8,
                Oct => 9,
                Nov => 10,
                Dec => 11
);

my %user;
my @calendar;
my @card;

for (my $l = @last; $l >=0; $l--)
{
    my $line = \$last[$l];
    if ($$line)
    {
        chomp $$line;
        #               saulo    pts/2   Tue     Feb     10      19  : 53     -    19  : 55      (00:01)
        #               1        2       3       4       5       6     7           8     9        10
        if ($$line =~ /^(\w+)\s+(\S+)\s+(\w+)\s+(\w+)\s+(\d+)\s+(\d+):(\d+)\s+-\s+(\d+):(\d+)\s+\((.*)\)/)
        {
            if ( ! exists $user{$1} ) { $user{$1} = (scalar keys %user); };
            my $user = $1;
            my $mon  = $4;
            my $day  = $5;
            my $inH  = $6;
            my $inM  = $7;
            my $ouH  = $8;
            my $ouM  = $9;
            my $dura = $10;
            if ($dura =~ /(\d+)\+(\d+):(\d+)/)
            {
                my $duraDay  = $1;
                my $duraHour = $2;
                my $duraMin  = $3;
                my $addMon   = $month{$mon};
                my $addDay   = $duraDay + $day;

                while (($addDay) > 31) { $addMon++; $addDay -= 31; };

                $calendar[$user{$user}][$addMon][$addDay][1][$ouH][$ouM] = 1;

                $ouH = undef;
                $ouM = undef;
            };
            print $$line, "\n"  if ($verbose >= 6);
            $calendar[$user{$user}][$month{$mon}][$day][0][$inH][$inM] = 1 if ((defined $inH) && (defined $inM));
            $calendar[$user{$user}][$month{$mon}][$day][1][$ouH][$ouM] = 1 if ((defined $ouH) && (defined $ouM));
        }
        elsif ( $$line =~ /still logged in/)
        {
            
        }
        elsif ( $$line =~ /down/)
        {
            
        }
        else
        {
            #print "oops, no match\t$$line\n";
        }
    }
}

foreach my $user (sort keys %user)
{
    print "REPORTING USER :: ",$user, "\n"  if ($verbose >= 2);
    for (my $m = 0; $m < 12; $m++)
    {
        my $Months = $calendar[$user{$user}][$m];
        if (defined $Months)
        {
            printf "  In %3s user logged in on %02d days\n", $month[$m], &countArray($Months) if ($verbose >= 1);
            for (my $d = 1; $d < 32; $d++)
            {
                my $Days = $Months->[$d];
                if (defined $Days)
                {
                    my $inMinHour;
                    my $inMinMinu;
                    my $inMaxHour;
                    my $inMaxMinu;
                    my $logins;

                    my @times;

                    if (defined $Days->[0])
                    {
                        $inMinHour = &min($Days->[0]);
                        $inMinMinu = &min($Days->[0][$inMinHour]);
                        $inMaxHour = &max($Days->[0]);
                        $inMaxMinu = &max($Days->[0][$inMaxHour]);

                        $times[$inMinHour][$inMinMinu] = 1;
                        $times[$inMaxHour][$inMaxMinu] = 1;
                        
                        $logins    = &countArray($Days->[0]);
                    }

                    my $outMinHour;
                    my $outMinMinu;
                    my $outMaxHour;
                    my $outMaxMinu;
                    my $logoffs;

                    if (defined $Days->[1])
                    {
                        $outMinHour = &min($Days->[1]);
                        $outMinMinu = &min($Days->[1][$outMinHour]);
                        $outMaxHour = &max($Days->[1]);
                        $outMaxMinu = &max($Days->[1][$outMaxHour]);

                        $times[$outMinHour][$outMinMinu] = 1;
                        $times[$outMaxHour][$outMaxMinu] = 1;

                        $logoffs = defined $Days->[1] ? &countArray($Days->[1]) : 0;
                    }

                    printf "    On day %02d the user logged in %02d times and logged off %02d times\n", $d, ($logins || 0), ($logoffs || 0) if ($verbose >= 2);

                    my $firstHour = &min(\@times);
                    my $firstMinu = &min(\@{$times[$firstHour]});
                    my $lastHour  = &max(\@times);
                    my $lastMinu  = &max(\@{$times[$lastHour]});;

                    my $totalMinu = ($lastHour > $firstHour) ? ($lastMinu + (60-$firstMinu)) : ($lastMinu - $firstMinu);
                    my $extraHour = 0;
                    if ($totalMinu >= 60) { $totalMinu -= 60; $extraHour +=1; };
                    my $totalHour = ($lastHour-$firstHour+$extraHour);

                    $card[$user{$user}][$m][0] += $totalHour;
                    $card[$user{$user}][$m][1] += $totalMinu;

                    printf "      IN::  first time at: %02d:%02d; last time at: %02d:%02d\n",            ($inMinHour  || 0), ($inMinMinu  || 0), ($inMaxHour  || 0), ($inMaxMinu  || 0) if ($verbose >= 5);
                    printf "      OUT:: first time at: %02d:%02d; last time at: %02d:%02d\n",            ($outMinHour || 0), ($outMinMinu || 0), ($outMaxHour || 0), ($outMaxMinu || 0) if ($verbose >= 5);
                    printf "      SUMMARY:: first login at: %02d:%02d and last log out at: %02d:%02d\n", ($inMinHour  || 0), ($inMinMinu  || 0), ($outMaxHour || 0), ($outMaxMinu || 0) if ($verbose >= 4);
                    printf "      SUMMARY:: first activity at: %02d:%02d and last activity at: %02d:%02d\n", $firstHour,  $firstMinu, $lastHour, $lastMinu if ($verbose >= 4);
                    printf "      TOTAL HOURS WORKING:: %02d:%02d\n", $totalHour, $totalMinu if ($verbose >= 3);
                }
            }
        }
    }
}


print "\n\n" if ($verbose >= 1);
foreach my $user (sort keys %user)
{
    print "REPORTING USER :: ",$user, "\n";
    for (my $m = 0; $m < 12; $m++)
    {
        my $Months = $card[$user{$user}][$m];
        if (defined $Months)
        {
            my $countDays = &countArray($calendar[$user{$user}][$m]);
            my $days      = 0;
            my $hours     = $Months->[0] || 0;
            my $minutes   = $Months->[1] || 0;
            while ($minutes >= 60) { $hours++; $minutes -= 60; };
            while ($hours   >=  8) { $days++;  $hours   -=  8; }
            printf "  %3s %02d shifts, %02d hours and %02d minutes in %02d week days\n", $month[$m], $days, $hours, $minutes, $countDays;
        }
    }
}


sub min
{
    my $array = shift;
    my $minI  = -1;
    if (ref $array ne 'ARRAY') { return -1; };
    for (my $i = 0; $i < @{$array}; $i++)
    {
        if (defined $array->[$i]) { $minI = $i; last;};
    }
    return $minI;
}

sub max
{
    my $array = shift;
    my $maxI  = 50;
    if (ref $array ne 'ARRAY') { return -1; };
    for (my $i = @{$array}; $i >= 0; $i--)
    {
        if (defined $array->[$i]) { $maxI = $i; last;};
    }
    return $maxI;
}

sub countArray
{
    my $array  = shift;
    my $totalI = 0;
    if (ref $array ne 'ARRAY') { return -1; };
    for (my $i = @{$array}; $i >= 0; $i--)
    {
        if (defined $array->[$i]) { $totalI++; };
    }
    return $totalI;
}
