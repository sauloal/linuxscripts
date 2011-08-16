#!/usr/bin/perl -w
use strict;

print "Content-type: text/html", "\n\n";

print "<html>
	<head>
		<title>VMSTAT</title>
	</head>
	<body>
		<div align=\"center\"><h1>VMSTAT</h1></div>
";

my @lines  = `vmstat`;
my @lines2 = `vmstat -s -S m`;

my $lineCount = 0;
print "\t"x2, "<div align=\"center\">\n";
print "\t"x3, "<table border=\"1px\">\n";

#procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu-----
# r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
# 1  0      0   6105    149    729    0    0     6     6  174  262  1  3 96  0  0	



while( my $line = shift @lines )
{
 print "\t"x4, "<tr>\n";
 chomp $line;
 $line =~ s/\s+/ /g;
 $line =~ s/\s/\t/g;
 my @fields = split(/\t/, $line);

  if ( $lineCount == 0)
  {
    for (my $f = 0; $f < @fields; $f++)
    {
      my $field = $fields[$f];
      my $span = 1;
      if ( $f == 0 ) { $span = 2; }
      if ( $f == 1 ) { $span = 4; }
      if ( $f == 2 ) { $span = 2; }
      if ( $f == 3 ) { $span = 2; }
      if ( $f == 4 ) { $span = 2; }
      if ( $f == 5 ) { $span = 5; }

      print "\t"x5, "<td colspan=$span><h3><b>$field</b></h3></td>\n";  
    } # end for
  } # end if
  elsif ($lineCount == 1)
  {
    shift @fields;
    foreach my $field (@fields)
    {
      print "\t"x5, "<td><h4><b>$field</b></h4></td>\n";
    }
  } else {
    shift @fields;
    foreach my $field (@fields)
    {
      print "\t"x5, "<td>$field</td>\n";
    }
  }
  print "\t"x4, "</tr>\n";
  $lineCount++;
}

print "\t"x3, "</table>\n";


print "\t"x3, "<br/>\n";


print "\t"x3, "<table>\n";
  print "\t"x4, "<tr>\n";
    print "\t"x5, "<td colspan=\"2\"><h2>MEMORY USAGE RESUME</h2></td>\n";
  print "\t"x4, "</tr>\n";

 print "\t"x4, "<tr>\n";
    print "\t"x5, "<td><h3>MEMORY</h3></td>\n";
    print "\t"x5, "<td><h3>NAME</h3></td>\n";
  print "\t"x4, "</tr>\n";


    foreach my $line (@lines2)
    {
      if ($line =~ /((\d+)\s+m?\s*)(.+)/ )
      {
        my ($mem, $name) = ($1, $3);
	chomp $mem;
        print "\t"x4, "<tr>\n";
          print "\t"x5, "<td><p align=\"right\">$mem</p></td>\n";
          print "\t"x5, "<td>$name</td>\n";
        print "\t"x4, "</tr>\n";
      } else {
        print "\t"x4, "<tr>\n";
          print "\t"x5, "<td colspan=\"2\">$line</td>\n";
        print "\t"x4, "</tr>\n";
      }
    }
print "\t"x3, "</table>\n";



print "\t"x2, "</div>\n";

print 
"	</body>
</html>
";
