#!/usr/bin/perl

# Wget4web (Web interface for Wget)
# Project page: http://irodov.nm.ru/wget4web/
#
# Copyright (C) 2002 Vladimir Filippov
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

use CGI qw(:standard);

require "data/info.cgi";    #Config

#Print info from log to delete in file
sub all_logs{
   my $endurl = $_[0];
   $endurl =~ s/.*\///;
   $endurl =~ s/\.log//;
   open(TEMPLOG, "+<$logsdir/temp_log");
   flock(TEMPLOG, LOCK_EX);
   my @templog = <TEMPLOG>;
   my ($i, $url, $username, $tempurl, $tempusername);
   for ($i = 0; $i <= $#templog; $i++){
      $_ = $templog[$i];
      ($tempurl, $tempusername) = /^(\S+) (\S+) /;
      if ($tempurl =~ /\/$endurl$/){
	 $url = $tempurl;
	 $username = $tempusername;
         $templog[$i] = undef;
      }
   }
   seek(TEMPLOG, 0, 0);
   print TEMPLOG @templog;
   truncate(TEMPLOG, tell(TEMPLOG));
   close(TEMPLOG);
   #View downloaded size in Wget log
   open (LOG, $_[0]); 
   my $downloaded;
   while (<LOG>){
      if (/ saved \[.*\]$/){
         $downloaded = $_;
	 last;
      }
   } 
   close(LOG);
   #Write to "all_logs" if something downloaded
   if (defined ($downloaded)){
      chomp($downloaded);
      $downloaded =~ s/.*\[//;
      $downloaded =~ s/\/.*//;
      $downloaded =~ s/\]//;     #If only [12345] without /
      open(ALLLOG, ">>$logsdir/all_logs");
      flock(ALLLOG, LOCK_EX);
      print ALLLOG "$url $downloaded $username\n";
      close(ALLLOG);
   }
}

#Print statistic
sub print_log{
   my $logname = $_[0];
   my(
      @logtext,
      $file_name,
      $i,
      $file_size,
      $file_speed,
      $file_procent,
      $file_status,
      $file_downloaded,
      $dots,
      $numberofdots,
   );
   open(LOG, $logname);
   @logtext=<LOG>;
   close (LOG);
   #Name of download file
   $file_name = $logname;
   $file_name =~ s/.*\///;
   $file_name =~ s/\.log$//;
   #Size of download file
   for ($i=0; ($i <= $#logtext) && ($logtext[$i] !~ /^Length: /); $i++){};
   if($i <= $#logtext){
      $file_size = $logtext[$i];
      chomp($file_size);
      $file_size =~ s/^Length: //;
      $file_size =~ s/ .*//;
      $file_size =~ s/,//g;
      if ($file_size =~ /\d/){
         $file_size /= 1024;
         $file_size =~ s/\..*//;
         $file_size .= "K";
      }
      else{
         $file_size = "?K";
      }
   }
   else{
      $file_size = "?K";
   }
   #Speed and procent of download file
   for ($i = $#logtext; ($i >= 0) && ($logtext[$i] !~ /B\/s$/); $i--){};    #xxx B/s
   if ($i >= 0){
      $file_speed = $logtext[$i];
      $file_speed =~ s/.*0K.* (\d*%)/$1/;
      chomp ($file_speed);
      $file_procent = $file_speed;
      $file_procent =~ s/ .*//;
      if ($file_procent !~ /%/){
         $file_procent = "? %";
      }
      $file_speed =~ s/.*% +//;
   }
   else{
      $file_speed = "? B/s";
      $file_procent = "0%";
   }
   #Status of download file
   if($logtext[$#logtext] =~ /0K /){     #xx50K or x100K .....
      $file_status = "Loding";
   }
   else{
      $file_status = "Error";
      if($#logtext <= 6){
         $file_status = "Begining";
      }
      if($file_procent =~ /\?/){
         $file_status = "?";
      }			   
      if($file_procent eq "100%"){
         $file_status = "Complete";
      }
      $file_speed = "";
   }
   #Downloaded size of file
   for ($i = $#logtext; ($i >= 0) && ($logtext[$i] !~ /0K /); $i--){};
   if ($i >= 0){
      $file_downloaded = $logtext[$i];
      $file_downloaded =~ s/K.*//;
      $dots = $logtext[$i];
      $dots =~ s/%.*//;
      for ($numberofdots = 0; $dots =~ /\.|,/; $numberofdots++){
         $dots =~ s/\.|,//
      };
      $file_downloaded += $numberofdots;
      $file_downloaded .= "K"; 
      
   }
   else{
      $file_downloaded = "0K";
   }
   my $nametoshow  = $file_name;
   my $len = 0;
   while ($nametoshow =~ /./g){
      $len++;
   }
   if ($len > 30){
      $nametoshow =~ s/(.{0,30}).*/$1\.\.\./;
   }
   #Output
   print ("<tr><td><a href=\"showlog.cgi?filename=$file_name\" title=\"Viev Wget log\" target=\"_blank\">$nametoshow</a></td><td align=right>$file_size</td><td align=right>$file_downloaded</td><td align=right>$file_procent</td><td align=right>$file_speed</td><td>&nbsp;</td><td>$file_status</td></tr>\n");
}

#Main program
my $logname;

print header(
   -type=>'text/html',
   -Cache_Control=>'no-cache'
);
print ("<HTML>\n<HEAD>\n<TITLE>Download information</TITLE>");
print ("<meta HTTP-EQUIV=\"Refresh\" CONTENT=\"$refreshstat\">\n");
print ("<meta HTTP-EQUIV=\"Pragma\" CONTENT=\"no-cache\">\n");
print ("</HEAD>\n\n<BODY>\n");
print ("<font face=\"Helvetica, Arial, sans-serif\">\n");

my $numberoflogs = 0;
while (defined ($logname = glob("$logsdir/*.log")) ){
   if (-M $logname >= $deletelogs){   #Delete logs and tasks files after $deletelogs days
      all_logs($logname);
      unlink($logname);
      my $taskname = $logname;
      $taskname =~ s/.*\///;   #Only file name
      $taskname =~ s/log$/task/;
      $taskname = $tasksdir."/".$taskname;
      unlink($taskname);  
   }
   else{
      if ($numberoflogs < 0.5){
         print ("<table>\n");
	 print ("<tr><td width=120><b>File name</b></td><td width=70 align=right><b>Size</b></td><td width=100 align=right><b>Downloaded</b></td><td width=100 align=right><b>Procent</b></td><td width=100 align=right><b>Speed</b></td><td width=20>&nbsp;</td><td width=100><b>Status</b></td></tr></b>\n");
      }	 
      print_log($logname);
      $numberoflogs ++;
   }
}

if ($numberoflogs < 0.5){
   print ("<H3>In last $deletelogs day(s) no files downloaded</H3>\n");
}
else{
   print ("</table>\n");
}

print ("</font>\n");
print ("</BODY>\n</HTML>");