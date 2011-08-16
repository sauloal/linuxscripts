#!/usr/bin/perl

for (my $i = 0; $i >= 0; $i++)
{
    print `ls -goth *.gz 2>/dev/null`;
    print `ls -goth *.lrz 2>/dev/null`;
    #exec 'pkill \-USR1 ^dd$';
    `pkill \-USR1 \^dd\$ &`;

    print "\n\n";

    sleep 60;
};

1;