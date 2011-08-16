#!/usr/bin/perl -w
use strict;

print "Content-type: text/html", "\n\n";

print 
"<html>
	<head>
		<title>PORTS</title>
	</head>
	<body>
		<div align=\"center\"><h1>PORTS</h1></div>
";


my @ip = `ifconfig`;
my @ips;
foreach	my $ip (@ip)
{
  if ($ip =~ /inet addr\:(\S*)/) 
  { 
    push(@ips, $1);
  } 
}

my %infos;
foreach	my $ip (@ips)
{
  push(@{$infos{$ip}}, `nmap -sT -F  $ip`);
}

print "\t"x2, "<div align=\"center\">\n";
print "\t"x3, "<table>\n";

#
#Starting Nmap 5.21 ( http://nmap.org ) at 2010-03-01 18:13 CET
#Nmap scan report for localhost.localdomain (127.0.0.1)
#Host is up (0.0070s latency).
#Not shown: 90 closed ports
#PORT      STATE SERVICE
#22/tcp    open  ssh

foreach my $ip (keys %infos)
{
  my @lines = @{$infos{$ip}};
  my $lineCount = 0;
  print "\t"x4, "<tr>\n";
  print "\t"x5, "<th colspan=3><h3><i>IP: $ip</i></h3></th>\n";
  print "\t"x4, "</tr>\n";
  print "\t"x4, "<tr>\n";
  print "\t"x5, "<td><h4><b>PORT</b></h4></td>\n";
  print "\t"x5, "<td><h4><b>STATE</b></h4></td>\n";
  print "\t"x5, "<td><h4><b>SERVICE</b></h4></td>\n";
  print "\t"x4, "</tr>\n";

  my $lines = (scalar @lines) -2;
  while( my $line = shift @lines )
  {
    chomp $line;
    $line =~ s/\s+/\t/g;
    my @fields = split(/\t/, $line);
    if (( $lineCount > 5 ) && ( $lineCount < $lines))
    {
      print "\t"x4, "<tr>\n";
      if (@fields > 1)
      {
        foreach my $field (reverse @fields)
        {
          print "\t"x5, "<td>$field</td>\n";
        }
      } else {
        print "\t"x5, "<td>EMPTY</td>\n";
        print "\t"x5, "<td>EMPTY</td>\n";
        print "\t"x5, "<td>EMPTY</td>\n";
      }
      print "\t"x4, "</tr>\n";
    }
    $lineCount++;
  }
}

print "\t"x3, "</table>\n";
print "\t"x2, "</div>\n";

print 
"	</body>
</html>
";
