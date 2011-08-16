#!/usr/bin/perl -w
#iostat -d -m -x sdc 1 1000 | gawk '{print $1 "\t" $3 "\t" $4 "\t" $6 "\t" $5 "\t" $7}'
use strict;
use Term::ANSIColor;

my $disk = $ARGV[0];
die if ( ! @ARGV );

my $graphSize   = 30;
my $iterations  = -1; # -1 to infinite


my $maxY        = 5;
my $minY        = 0;
my $maxId       = length($graphSize); # length of id string

my @graphLine;
my %header2color;
my @colors    = ('BLUE', 'RED', 'yellow' ,'green', 'cyan', 'magenta');
my $lastColor = 0;
my $topY = 0;


my $clearCommand = $^O eq 'MSWin32' ? 'cls' : 'clear';
system $clearCommand;

my $command =   'iostat -d -m -x ' . $disk . ' 1 2 | gawk ' . 
                '\'{print $1 "\t" $6 "\t" $7}\'';
#print $command, "\n";



while (1)
{
    my @lines = `$command`;
    $maxY        = 5;
    if ($lines[6] =~ /$disk/)
    {
        &graph(abs($iterations), @lines[5 .. 6]);
    }
    else
    {
        die "DISK $disk DOESNT EXISTS IN @lines";
    }
    sleep 1;

    if    ($iterations  > 0 ) { $iterations-- }
    elsif ($iterations == 0 ) { last; }
    else  {$iterations--; };
}

sub graph
{
    my $id    = $_[0];
    my @lines = @_[1 .. (@_-1)];
    chomp @lines;
    
    my @data;

    @{$data[0]} = split(/\s/, $lines[0]); # header
    @{$data[1]} = split(/\s/, $lines[1]); # data

    if (@{$data[0]} && @{$data[1]})
    {
                my @headers = @{$data[0]}[1 .. (@{$data[0]} -1)]; 
                my @values  = @{$data[1]}[1 .. (@{$data[1]} -1)];

        &plotGraphic($id, \@headers, \@values);
    }
    else
    {
        die "COULD NOT PARSE OUTPUT: @lines";
    }
}


sub plotGraphic
{
    my $id      = $_[0];
    my $headers = $_[1];
    my $values  = $_[2];

#   print "ID:$id DEVICE:$disk";
    if (@graphLine >= $graphSize) { shift(@graphLine); };
    my $index = @graphLine;


    for (my $hv = 0; $hv < @{$headers}; $hv++)
    {
        print uc($headers->[$hv]), ": ", $values->[$hv], "  ";
        print "ADDING ", $index, " x ", $hv, " = VALUE: ", $values->[$hv],"\n";
        $graphLine[$index]{"id"}            = $id;
        $graphLine[$index]{$headers->[$hv]} = $values->[$hv];

        if ( ! exists $header2color{ $headers->[$hv] } ) 
        { 
            $header2color{ $headers->[$hv] } = $colors[$lastColor++]; 
        };

        #$maxId = length($id) if (length($id) > $maxId);
        $topY = int($values->[$hv] + 0.5) if ($values->[$hv] > $topY);
    }

    &drawGraphic();
}

sub drawGraphic
{
    system $clearCommand;

    #print color 'bold blue';
    #print "This text is bold blue.\n";
    #print color 'reset';
    #http://perl.active-venture.com/lib/Term/ANSIColor.html

    my $blockLength = (scalar keys %header2color);
#   $blockLength    = $maxId if ($maxId > $blockLength);
#   $blockLength   += 1;

    for ( my $index = 0; $index < @graphLine; $index++)
    {
        foreach my $key (sort keys %{$graphLine[$index]})
        {
            next if ($key eq "id");
            my $current = int($graphLine[$index]{$key} + .5);
            $maxY = $current if ($current > $maxY);
            $minY = $current if ($current < $minY);
        }
    }

    my $lengthLine = (((length $maxY) + 2 + ($blockLength*(@graphLine))) + 2);
    print "-" x $lengthLine, "\n";
#   print "-" x (((length $maxY) + 2 + ((($blockLength-$maxId)+(scalar keys %header2color))*@graphLine)) + 5), "\n";

    for ( my $y = $maxY; $y >= $minY; $y--)
    {
        printf "%0" . (length $maxY) . "d |", $y;

        for ( my $index = 0; $index < @graphLine; $index++)
        {
            my @string;
            foreach my $key (sort keys %{$graphLine[$index]})
            {
                next if ($key eq "id");
                my $current = int($graphLine[$index]{$key});
                if ($current == $y)
                {
                    #print colored ("test", $header2color{$key});
                    my $string;
                    if ( defined $graphLine[$index+1] )
                    {
                        my $next = int($graphLine[$index+1]{$key});
                        if ($next >  $current)
                        {
                            #print colored ("\/", "bold " . $header2color{$key}) 
                            $string = "\/";
                        }
                        elsif ($next <  $current)
                        {
                            #print colored ("\\", "bold " . $header2color{$key}) 
                            $string = "\\";
                        }
                        else
                        {
                            #print colored ("-",  "bold " . $header2color{$key}) 
                            $string = "-";
                        }
                    }
                    else
                    {
                        #print colored (".", "bold " . $header2color{$key});
                        $string = ".";
                    }
                    my $pos = @string;
                    $string[$pos][0] = $string;
                    $string[$pos][1] = $header2color{$key};
                    #print colored ($string, "bold " . $header2color{$key});
                } # end if value eq y
            } # end foreach my key

            print " "x($blockLength-@string);
            for (my $s = 0; $s < @string; $s++)
            {
                my $str = $string[$s];
                print colored ($str->[0], "bold " . $str->[1]);
            }
        } # end for my index
        print "|\n"
    } # end for my Y

    print "-" x $lengthLine, "\n";
#   print "-" x (((length $maxY) + 2 + ((($blockLength-$maxId)+(scalar keys %header2color))*@graphLine)) + 5), "\n";
    printf "%0" . (length $maxY) . "d |", 0;

    for ( my $index = 0; $index <= @graphLine; $index++)
    {
        if (((($index+1) % 2)) && ($index))
        {
            print " "x($blockLength);
            printf "%0". $blockLength ."d", $index;
        }
    }
    print "\n";

    foreach my $key (sort keys %header2color)
    {
        print color $header2color{$key};
        print $key , ": ",$graphLine[@graphLine-1]{$key},"\t";
        print color 'reset';
    }
    print "TOP USAGE:",$topY,"\n";


}

exit 0;


1;