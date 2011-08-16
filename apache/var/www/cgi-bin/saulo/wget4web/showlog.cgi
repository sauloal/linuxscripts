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

my $logname = param ("filename");

print header(
   -type=>'text/html',  
   -Cache_Control=>'no-cache'  
); 
print ("<HTML>\n<HEAD>\n");
print ("<TITLE>Wget log of $logname</TITLE>\n"); 
print ("</HEAD>\n\n<BODY>\n");
$logname =~ s/.*\///;        #For security
$logname =~ s/([^a-zA-Z0-9_%:@\-\.])/'%'.unpack("H2",$1)/ge;   #For security
$logname = $logsdir . "/" . $logname . ".log";
if (open (LOG, $logname)){
   print ("<PRE>\n");
   while (<LOG>){
      print;
   }
   print ("</PRE>\n");
}
else{
   print ("<H2>Can't open $logname</H2>\n");
}

print ("</BODY>\n</HTML>");
