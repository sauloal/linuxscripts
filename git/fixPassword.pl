#!/usr/bin/perl -w
use strict;
use File::Copy;
use File::Basename;
use FindBin qw($Bin);
use lib "$Bin/lib";
use readpass;

my $FORCEMOVE = 0;

die "NO FORBIDDEN FILE DEFINED" if ( ! -f './forbid' );
my $secr   = new readpass(inFile => './forbid');
my @allow  = ( -f 'allowed'  ) ? `cat allowed`  : ();
my @allowr = ( -f 'allowedr' ) ? `cat allowedr` : ();

my $PASS   = $secr->getValue("git_forbidden_pass");
my $FOLDER = $ARGV[0];

die "NO PASSWORK PASSED\n" if ( ! defined $PASS   );
die "NO FOLDER DEFINED\n"  if ( ! defined $FOLDER );

#print "SEARCHING FOR \"$PASS\" ON \"$FOLDER\"\n";

my @FILES    = `find $FOLDER -xdev -readable -xtype f `;
my @secrets  = split(/\|/, $PASS);
my @replaces = @secrets;
map { $_ =~ s/./X/g } @replaces;

#print join(", ", @secrets);


foreach my $file ( @FILES ) {
	chomp $file;
	next if $file =~ /\.git\//;

	foreach my $allowed ( @allow ) {
		next if $file =~ /\Q$allowed\E/;
	}

	foreach my $allowed ( @allowr ) {
		next if $file =~ /$allowed/;
	}

	my $base = basename($file);


	my $type = `file --brief --mime-type $file`;
	chomp $type;
	if (	( $type !~ /^text/        ) && 
		( $type !~ /xml/          ) &&
		( $type !~ /opendocument/ )
	   ) {
		#print "  FILE '$file' [$base] ::  WRONG TYPE '$type'. SKIPPING\n";
		next;
	} else {
		#print "  FILE '$file' [$base]\n";
		#print "    TYPE '$type'\n\n";
	}

	#print "CREATING BAK\n";
	my $bak = $file;
	   $bak =~ s/\//\+/g;
	   $bak = "$Bin/$bak.bak";
	#copy($file, $bak);

	#print "BLURPING\n";
	open FI, "<$file" or die "COULD NOT OPEN $file: $!\n";
	my @subCount;
	my $subCount = 0;
	my @lines    = <FI>;
	my $text     = join("", @lines);
	close FI;
	#print "BLURPED : [".(scalar @lines)."] $text\n";

	for ( my $s = 0; $s < @secrets; $s++ ) {
		my $secret  = $secrets[$s];
		my $replace = $replaces[$s];
		
		#print "    SECRET \'$secret\' TO $replace\n";

		my $count = $text =~ s/$secret/$replace/gim;
		$subCount += $count;
		push(@subCount, [$secret, $count]) if $count != 0;
	}

	#print "COUNT $subCount\n";

	if ( $subCount == 0 ) {
		#print "UNLINKING BAK\n";
		#unlink("$bak");
		#print "FILE '$file' ... PASS\n";
	} else {
		print "UNLINKING FILE '$file'. FOUND SECRETS\n";
		print "   ", join(", ", map{$_->[0] . " => " . $_->[1]} @subCount), "\n";
		#exit;
		copy($file, $bak);

		if ( $FORCEMOVE ) {
			if ( ! -f $bak ) {
				die "ERROR CREATING BACKUP '$bak': $!\n";
			} else {
				unlink("$file");
				if ( $! ) {
					die "ERROR DELETING FILE '$file': $!\n";
				}
			
				open FO, ">$file" or die "COULD NOT OPEN $Bin/$file: $!\n";
				print FO $text;
				close FO;

				if ( ! -f $file ) {
					die "ERROR RESTORING FILE '$file': $!\n";
				}
			}
		}
	}

	#print "    SECRET \'$secret\' TO $replace\n";
	#my $cmd = "sed -i.bak -e 's/$secret/$replace/' '$file'; if [[ -f '$file.bak' ]]; then mv '$file.bak' '$Bin/$base.bak'; fi;";
	#my $cmd = "sed -i.bak -e 's/$secret/$replace/' '$file'; if [[ -f '$file.bak' ]]; then mv '$file.bak' '$Bin/$base.bak'; fi;";
	#print "      CMD '$cmd'\n";
	#print `$cmd`; 
}

