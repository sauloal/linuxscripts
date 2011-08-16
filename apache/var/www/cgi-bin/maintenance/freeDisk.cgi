#!/usr/bin/perl -w
use strict;

print "Content-type: text/html", "\n\n";

print "<html>
	<head>
		<title>FREE DISK</title>
	</head>
	<body>
		<div align=\"center\"><h1>FREE DISK</h1></div>
";

my @lines = `df -hT --total`;
my $lineCount = 0;
print "\t"x2, "<div align=\"center\">\n";
print "\t"x3, "<table>\n";
while( my $line = shift @lines )
{
 print "\t"x4, "<tr>\n";
 chomp $line;
 $line =~ s/Mounted on/Mounted/;
 $line =~ s/(\w)\s(\w)/$1\t$2/g;
 $line =~ s/\s+/\t/g;
 my @fields = split(/\t/, $line);

 if ( ! $lineCount++ )
 {
  foreach my $field (@fields)
  {
    print "\t"x5, "<td><h3><b>$field</b></h3></td>\n";  
  }
 } else {
  foreach my $field (@fields)
  {
    print "\t"x5, "<td>$field</td>\n";
  }
 }
 print "\t"x4, "</tr>\n";
}
print "\t"x3, "</table>\n";
print "\t"x2, "</div>\n";

print 
"	</body>
</html>
";
