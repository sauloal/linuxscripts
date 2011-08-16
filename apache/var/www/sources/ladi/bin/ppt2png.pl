
# LAboratory Document Indexer (LADI)
# http://mkweb.bcgsc.ca/ladi
# martink@bcgsc.ca
#
# Usage: 
#
# ppt2png.pl
#
# Configuration:
#
# Adjust $digester, $converter, $thumbpath, $docpath, and $overwrite for your
# configuration. See
#
# http://mkweb.bcgsc.ca/ladi/?thumbnails
#
# for details.
#
# md5sum.exe and convert.exe are bundled with LADI (bin/).

use strict;
use Win32::OLE;
use File::Path;
use File::Find;
use Data::Dumper;
use Image::Magick;
use IO::File;

my $digester  = "c:\\ppt2png\\md5sum.exe";
my $converter = "c:\\ppt2png\\convert.exe";
my $thumbpath = "z:\\www\\htdocs\\ladi\\thumbnails";
my $docpath   = "z:\\www\\htdocs\\ladi\\ladi_repository\\presentations";
my $overwrite = 0;

# look through the doc path and process all ppt images
find(\&process,$docpath);

exit;

sub process {
  my $file = $File::Find::name;
  # gotta be a ppt file - which we check using the extension
  next unless $file =~ /\.ppt$/i;
  my $digest = makedigest($file);
  my $pngpath = "$thumbpath\\$digest";
  if(-d $pngpath && ! $overwrite) {
    # we already have this directory
    printf("%s EXISTS\n",$file);
    next;
  }
  printf("%s %s %s\n",$file,$digest,$pngpath);
  my $ok = exportpng($file,$pngpath);
  processpng($pngpath,$digest) if $ok;
}

sub processpng {
  my ($path,$digest) = @_;
  my @files = glob("$path/Slide*");
  for my $file (@files) {
    my ($num) = $file =~ /Slide(\d+)/;
    print "$file $num\n";
    my $newfile = sprintf("%s-%03d.png",$digest,$num-1);
    my $command = "$converter -scale 400x300 -unsharp 1.5x1.2+1.0+0.10 $file $path\\$newfile";
    print "$command\n";
    system($command);
    unlink($file);
  }
}

sub makedigest {
    my $file = shift;
    my $digest = `$digester $file`;
    chomp $digest;
    ($digest) = split(" ",$digest);
    return $digest;
}

sub exportpng {
    my ($file,$path) = @_;
    print "launching powerpoint\n";
    my $ppt = Win32::OLE->new("Powerpoint.Application",sub {$_[0]->Quit});
    print "setting visible\n";
    $ppt->{Visible}=1;
    print "opening $file\n";
    my $ok;
    my $pres;
    eval {
      my $pres = $ppt->Presentations->Open($file);
      print Win32::OLE->LastError() unless $pres;
      print "exporting png to $path\n";
      mkpath($path);
      $pres->Export($path,"png");
    };
    if($@) {
      print "problem reading $file into powerpoint\n";
      $ok = 0;
    } else {
      $ok = 1;
    }
    undef $pres;
    undef $ppt;
    return $ok;
}
