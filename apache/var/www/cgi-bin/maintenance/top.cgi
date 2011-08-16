#!/usr/bin/perl -w
use strict;

print "Content-type: text/html", "\n\n";

print "<html>
	<head>
		<title>TOP</title>
	</head>
	<body>
		<div align=\"center\"><h1>TOP</h1></div>
";

my @lines = `top -b -n 1`;
my $lineCount = 0;
print "\t"x2, "<div align=\"center\">\n";
print "\t"x3, "<table>\n";
while( my $line = shift @lines )
{
  chomp $line;
  next if ( ! $line ); 
  print "\t"x4, "<tr>\n";

  if ( $lineCount < 5)
  {
    print "\t"x5, "<td colspan=12><pre>$line</pre></td>\n";  
  } else {
    $line       =~ s/(\w)\s(\w)/$1\t$2/g;
    $line       =~ s/\s+/\t/g;
    my @fields  =  split(/\t/, $line);
    my $tdCount =  0;

    shift(@fields);
    foreach my $field (@fields)
    {
      if ( $lineCount == 5)
      {
        print "\t"x5, "<td><h3><b>$field</b></h3></td>\n";
      } else {
        print "\t"x5, "<td>$field</td>\n";
      }
      $tdCount++;
    }
  }
  print "\t"x4, "</tr>\n";
  $lineCount++;
}

print "\t"x3, "</table>\n";
print "\t"x2, "</div>\n";

print 
"	</body>
</html>
";
