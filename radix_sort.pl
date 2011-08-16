#!/usr/bin/perl -w
use strict;

my @input = qw( wolf boar hawk bear pike lion lynx puma bume );
print "BEFORE ", join(" ", @input), "\n";
&radix_sort(\@input);
print "AFTER  ", join(" ", @input), "\n";

sub radix_sort
{
	my $array = shift;
	my $from  = $array;
	my $to;

	#all lengths expected equal
	for (my $i = (length( $array->[0] ) - 1); $i >= 0; $i--)
	{
		#A new sorting bin
		$to = [ ];
#		print "\tI $i\n";
		foreach my $card (@$from)
		{
			#print "\t\t$i CARD: $card\n";
			#stability is essential, so use push();
			my $subStr  = substr($card, $i);
			my $toValue = ord($subStr); # ord just gives the value to the first character
			#print "\t\t\tSUBSTR $subStr TO VALUE: $toValue\n";
			push @{ $to->[ $toValue ] }, $card;
		}
		#contatenate the bins
		for (my $tos = 0; $tos < @$to; $tos++)
		{
			next if ( ! $to->[$tos] );
			#print "\t\t\t$tos = ", ($to->[$tos] || ""), "\n";
			for (my $sub = 0; $sub < @{$to->[$tos]}; $sub++)
			{
				next if ( ! $to->[$tos]->[$sub] );
			#	print "\t\t\t\t$sub = ", $to->[$tos]->[$sub], "\n"
			}
		}

#		$from  = [ map { @{ $_ || [] } } @$to ]; # create new array
		@$from = map { @{ $_ || [] } } @$to ;
	}

	# now copu the elements back into the original array
#	@$array = @$from; # copy back array
}
