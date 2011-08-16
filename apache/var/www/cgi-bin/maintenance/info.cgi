#!/usr/bin/perl -w
use strict;

print "Content-type: text/html", "\n\n";

print "<html>
	<head>
		<title>INFO</title>
	</head>
	<body>
		<div align=\"center\"><h1>INFO</h1></div>
";

my @info;

#.	uname -a	Show kernel version and system architecture
$info[0][0] = "Kernel Name";
$info[0][1] = `uname -a 2>/dev/null`;

#.	head -n1 /etc/issue	Show name and version of distribution
$info[1][0] = "Ditribution Name and Version";
$info[1][1] = `head -n1 /etc/issue 2>/dev/null`;

#.	cat /proc/partitions	Show all partitions registered on the system
$info[2][0] = "Partitions";
$info[2][1] = `cat /proc/partitions 2>/dev/null`;

#.	grep MemTotal /proc/meminfo	Show RAM total seen by the system
$info[3][0] = "Totam RAM";
$info[3][1] = `grep MemTotal /proc/meminfo 2>/dev/null`;

#.	grep "model name" /proc/cpuinfo	Show CPU(s) info
$info[4][0] = "Processor Model Name";
$info[4][1] = `grep "model name /proc/cpuinfo 2>/dev/null` ;

#.	lspci -tv	Show PCI info
$info[5][0] = "PCI info";
$info[5][1] = `lspci -tv 2>/dev/null`;

#.	lsusb -tv	Show USB info
$info[6][0] = "USB info";
$info[6][1] = `lsusb -tv 2>/dev/null`;

#.	mount | column -t	List mounted filesystems on the system (and align output)
$info[7][0] = "mounted filesystems";
$info[7][1] = `mount | column -t 2>/dev/null`;

#.	grep -F capacity: /proc/acpi/battery/BAT0/info	Show state of cells in laptop battery
$info[8][0] = "Battery State";
$info[8][1] = `grep -F capacity: /proc/acpi/battery/BAT0/info 2>/dev/null`;


$info[8][0] = "Last Fail";
$info[8][1] = `dmesg | tail -50 2>/dev/null`;

$info[9][0] = "Last Apache Access";
$info[9][1] = `tail -50 /var/log/httpd/access_log 2>/dev/null`;

$info[10][0] = "Last Apache Error";
$info[10][1] = `tail -50 /var/log/httpd/error_log 2>/dev/null`;





my $lineCount = 0;
print "\t"x2, "<div align=\"center\">\n";
print "\t"x3, "<table>\n";
while( my $nfo = shift @info )
{
 print "\t"x4, "<tr>\n";
 my $title = $nfo->[0];
 my $data  = $nfo->[1];
 chomp $data;
 print "\t"x5, "<td><font size=4><b>$title</b></font></td>\n";
 print "\t"x5, "<td><pre>$data</pre></td>\n";

 print "\t"x4, "</tr>\n";
}
print "\t"x3, "</table>\n";
print "\t"x2, "</div>\n";

print "
	</body>
</html>
";
