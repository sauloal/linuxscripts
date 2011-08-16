#!/usr/bin/perl

my @array;

#4 ** 24 = 2 ** 48
#48 bits

for (my $p = 0; $p <= 48; $p++)
{
	print "adding to $p\n";
	$array[2 ** $p] = 1;
}

if (0)
{
	for (my $p = 0; $p <= 48; $p++)
	{
		my $value  = 2 ** $p;
		my $valueS = &pointer($value);
		my $bytes  = ($value / 8);
		my $bytesS = &pointer($bytes);
		my $kBytes  = ($bytes / 1024);
		my $kBytesS = &pointer($kBytes);
		my $mBytes  = ($kBytes / 1024);
		my $mBytesS = &pointer($mBytes);
		my $gBytes  = ($mBytes / 1024);
		my $gBytesS = &pointer($gBytes);
		my $tBytes  = ($gBytes / 1024);
		my $tBytesS = &pointer($tBytes);

		print "FOR P = $p; 2 ** $p = ", $valueS, " [$value] POSSIBILITIES\n";
		print "\t$valueS  bits   = ", $bytesS, "  BYTES\n";
		print "\t$bytesS  bytes  = ",$kBytesS, " KBYTES\n";
		print "\t$kBytesS Kbytes = ",$mBytesS, " MBYTES\n";
		print "\t$mBytesS Mbytes = ",$gBytesS, " GBYTES\n";
		print "\t$gBytesS Gbytes = ",$tBytesS, " TBYTES\n";

	}
}

sub pointer
{
	my $value = $_[0];
	my $valueS;
	for (my $c = 0; $c < length($value) ; $c++)
	{
		$valueS .= substr($value, $c, 1);
		if ( ! (($c - length($value) + 1) % 3) ) {$valueS .=  "."; };
	}

	chop $valueS;
	return $valueS;
}
