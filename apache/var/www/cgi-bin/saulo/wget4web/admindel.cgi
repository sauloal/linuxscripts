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
require "admin.lib";

$login = cookie ('userlogin');
$password = cookie ('userpass');

print header();
print ("<HTML>\n<HEAD>\n");
print ("<TITLE>Delete files</TITLE>\n");
print ("<TABLE width=550>\n<TR>\n<TD valign=top>");
leftmenu();
print ("</TD>\n<TD valign=top width=\"*\">\n");

my $userstatus = testuser($login, $password);
if ($userstatus eq "guest"){
   userlogin();
}
else{   
   open (TEMPLOG, "+<$logsdir/temp_log") || print("<p><b>Can't open $logssdir/temp_log for write</b>\n");
   flock(TEMPLOG, LOCK_EX);
   my @templog = <TEMPLOG>;    
   my ($filename, $user, $pid, @psresult, $counter);
   my @pidstodel = param("todo");
   if (@pidstodel){
      my $action = param("action");
      my $i;
      for($i = 0; $i <= $#pidstodel; $i++){
         seek(TEMPLOG, 0, 0);
         while (<TEMPLOG>){
	    ($filename, $user, $pid) = /^(\S+) (\S+) (\S+)$/;
	    $filename =~ s/.*\///;
	    if ($pid eq $pidstodel[$i]){
	       if (($user eq $login) || ($userstatus eq "admin")){
	          $pid =~ s/\D//g;     #For security
	          if (system ("kill -TERM $pid")){
		     print("<p><b>Can't kill Wget with pid $pid. Downloading file $filename countining...</b>\n");
	          }else{
		     unlink ("$tasksdir/$filename.task") || print("<p><b>Can't delete task file $tasksdir/$filename.task</b>\n");
	             unlink ("$logsdir/$filename.log") || print("<p><b>Can't delete log file $logsdir/$filename.log</b>\n");
	             #Delete lines in temp log
	             my ($j, $url);
	             for($j = 0; $j <= $#templog; $j++){
	                $_ = $templog[$j];
		        ($url) = /^(\S+)/;
		        if ($url =~ /\/$filename$/){
		           $templog[$j] = undef;
		        }
	             }
	             #End of delete lines in temp log
	             if ($action eq "delete"){
	                unlink ("$filesdir/$filename") || print("<p><b>Can't delete $filesdir/$filename</b>\n");
	             }
                  }		
               }else{
	          print ("<p><b>You can't delete file $filename, because some one else start this loading and you not admin</b>\n"); 
               }
            }
         }
      }
   }
   seek(TEMPLOG, 0, 0);
   print TEMPLOG @templog;
   truncate(TEMPLOG, tell(TEMPLOG));
   close(TEMPLOG);
   my $color = "#000000";
   #Begin main info
   print ("<CENTER>\n");
   print ("<H3>Active downloads</H3>\n");
   print ("<TABLE>");
   print ("<form action=\"admindel.cgi\" method=\"post\">\n");
   open (TEMPLOG, "+<$logsdir/temp_log") || print("<p><b>Can't open $logssdir/temp_log for read</b>\n");
   while (<TEMPLOG>){
      ($filename, $user, $pid) = /^(\S+) (\S+) (\S+)$/;
      $pid =~ s/\D//g;        #For security
      $filename =~ s/.*\///;
      @psresult = `ps -p $pid`;
      if ($psresult[1] =~ /wget/){
         $counter++;
	 if ($user eq $login){
	    $color = "#006600";
	 }
	 print ("<TR><TD><font color=$color>$filename</font></TD><TD><input type=\"checkbox\" value=\"$pid\" name=\"todo\"></TD></TR>\n");
         $color = "#000000";
      }
   }
   print ("</TABLE>\n");
   if (defined($counter)){
      print ("<TABLE><TR><TD align=left>\n");
      print ("<BR><input type=\"radio\" name=\"action\" value=\"stop\" checked>Stop downloading\n");
      print ("<BR><input type=\"radio\" name=\"action\" value=\"delete\">Stop downloading, delete downloaded files\n");
      print("</TD></TR></TABLE>\n");
      print ("<P><input type=\"submit\" value=\"Do it!\">&nbsp;&nbsp;<input type=reset value=\"Cancel\">\n");
   }else{
      print ("<P>No active downloads\n");
   }
   print ("</form>\n");
   #End main info
   close (TEMPLOG);
}

print ("</TD></TR></TABLE></BODY>\n</HTML>");