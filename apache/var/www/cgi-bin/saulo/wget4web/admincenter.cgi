#!/usr/bin/perl -w

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

sub good_number{
   my $bytes = $_[0];
   if ($bytes / 1024 < 1){
   }elsif (($bytes /= 1024) < 1024){
      $bytes =~ s/\.\d*//;
      $bytes .= " Kb";
   }elsif (($bytes /= 1024) < 1024){
      $bytes =~ s/\.\d*//;
      $bytes .= " Mb";
   }else{
      $bytes /= 1024;
      if ($bytes < 100){
         $bytes =~ s/\.(\d).*/\.$1/;
      }else{
         $bytes =~ s/\.\d*//;
      } 
      $bytes .= " Gb";
   }
   return ($bytes);
}

my $action = param ("action");
if ($action eq "login"){
   $login = param ("login");
   $password = param ("password");
   print "Set-Cookie: userlogin=$login\;";
   print "\n";
   print "Set-Cookie: userpass=$password\;";
   print "\n";
}
else{
   $login = cookie ('userlogin');
   $password = cookie ('userpass');
}   

print header();
print ("<HTML>\n<HEAD>\n");
print ("<TITLE>Summary statistic</TITLE>\n");
print ("<TABLE width=550>\n<TR>\n<TD valign=top>");
leftmenu();
print ("</TD>\n<TD valign=top width=\"*\">\n");

if (testuser($login, $password) eq "guest"){
   userlogin();
}
else{   
   open (ALLLOG, "$logsdir/all_logs");
   my ($size, $name, $total, %users, $numfile);
   while (<ALLLOG>){
      (undef, $size, $name) = /^(\S+) (\S+) (\S+)$/;
      $total += $size;
      $users{$name} += $size;
      $numfile ++;
   }
   close(ALLLOG);
   #Begin main info
   print ("<CENTER>\n");
   print "<h3>Total downloaded: ", good_number($total), " in $numfile files</H3>\n";
   print ("<TABLE border=0 bgcolor=#000000 cellpadding=0 cellspacing=0>\n");
   print ("<TR><TD>\n\n");
   print ("<TABLE BORDER=0 CELLPADDING=3 CELLSPACING=1>\n");
   print ("<TR bgcolor=#eeeeee><TH width=100>User name</TH><TH>Downloaded</TH></TR>\n");
   foreach $name (sort keys %users){
      print"<TR bgcolor=#ffffff><TD>$name</TD><TD>", good_number($users{$name}), "</TD></TR>\n";
   }
   print ("</TABLE>\n\n");
   print ("</TD></TR>\n</TABLE>");
   print ("</CENTER>\n");
   #End main info
}

print ("</TD></TR>\n");
print ("</TABLE>\n</BODY>\n</HTML>");