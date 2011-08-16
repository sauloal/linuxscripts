#!/usr/bin/perl -w
use strict;

print "Content-type: text/html", "\n\n";

print "<html>
	<head>
		<title>COMPUTERS</title>
	</head>
	<body>
		<div align=\"center\"><h1>COMPUTERS</h1></div>
";

my @lines = `nmap -sL 192.168.1.70-100`;
my $lineCount = 0;
print "\t"x2, "<div align=\"center\">\n";
print "\t"x3, "<table>\n";
print "\t"x4, "<tr>\n";
print "\t"x5, "<td><h3><b>NAME</b></h3></td>\n";
print "\t"x5, "<td><h3><b>IP</b></h3></td>\n";
print "\t"x4, "</tr>\n";

#Nmap scan report for saulo-nettop.lan (192.168.1.72)
#Nmap scan report for 192.168.1.73

while( my $line = shift @lines )
{
 chomp $line;
 $line =~ s/Nmap scan report for //g;
 $line =~ s/\s+/\t/g;
 $line =~ s/\(//g;
 $line =~ s/\)//g;
 my @fields = split(/\t/, $line);

 if (( $lineCount++ > 1 ) && ( @lines ))
 {
   print "\t"x4, "<tr>\n";
   if (@fields > 1)
   {
     foreach my $field (reverse @fields)
     {
       print "\t"x5, "<td>$field</td>\n";
     }
   } else {
     print "\t"x5, "<td>", $fields[0], "</td>\n";
     print "\t"x5, "<td>EMPTY</td>\n";
   }
   print "\t"x4, "</tr>\n";
 }
}
print "\t"x3, "</table>\n";
print "\t"x2, "</div>\n";

print "
	</body>
</html>
";
