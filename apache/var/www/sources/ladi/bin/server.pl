#!/usr/bin/perl -w

# LAboratory Document Indexer (LADI)
# http://mkweb.bcgsc.ca/ladi
# martink@bcgsc.ca
#
# v0.30
#
# Server-side script. Run this on the Windows machine on which GDS is installed. 
#
# This script mediates conversation between the LADI client (running on a remote machine) and
# the local GDS process.
#
#                    GDSWEBHOST                 GDSHOST
#                                               ------------------------------------
# remote   --------- LADI client   ------------ | LADI server    ---- LADI service |
# user               (web script)               | (this script)                    |
#                                               ------------------------------------
#
# The LADI client web script sends the user's query to this script using XML-RPC.
#

use strict;
use LWP::UserAgent;
use Data::Dumper;
use Frontier::Daemon;

my $daemon = Frontier::Daemon->new(LocalPort=>34203,methods => {'remotegds' => \&search }) or die "could not initialize daemon: $!";   
print $daemon;

sub search  {

   my %args = @_;
   my $ua = LWP::UserAgent->new;

   my $agent = $args{agent} || "LADI";
   $ua->agent($agent);

   my $host    = $args{ip}     || "127.0.0.1";
   my $port    = $args{port}   || 34202;
   my $siteid  = $args{siteid} || return undef;
   my $format  = $args{format} || "xml";

   my $gdsurl  = $args{gdsurl};

   # remove filetype:WORD from query
   $args{query} =~ s/filetype\s*:\s*\w//;

   while( $gdsurl =~ /(_\w+?_)/g ) {
     my $keystring = $1;
     (my $keyword = $keystring) =~ s/_//g;
     if($args{uc $keyword} || $args{lc $keyword}) {
       my $value = $args{uc $keyword} || $args{lc $keyword};
       #print "keyword $keyword value $value\n";
       $gdsurl =~ s/$keystring/$value/g;
     } else {
       #print "keyword $keyword no value\n";
       $gdsurl =~ s/$keystring//;
     }
     #print "intermediate $gdsurl\n";
   }

   print "$gdsurl\n";

   my $response = $ua->get($gdsurl);

   if($response->is_success) {
     my $content = $response->content;
     $content =~ s/\cK//g;
     return $content;
   } else {
     return undef;
   }
 }


