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


sub goodpassword{
   my $name = $_[0];
   my $password = $_[1];
   my (
      $nametemp,
      $passwordtemp,
      $result,
   );
   $result = 0;
   open (USERS, "data/users.cgi");
   while (<USERS>){
      chomp();
      ($nametemp, $passwordtemp) = split(/\|/);
      if (($nametemp eq $name) && ($passwordtemp eq $password)){
         $result = 1;
      }
   }
   close(USERS);
   return ($result);
}


#Begin program
my $i;
print header();
print ("<HTML>\n<HEAD>\n<TITLE>Wget4web: Web interface for Wget</TITLE>");
print ("<meta HTTP-EQUIV=\"Pragma\" CONTENT=\"no-cache\">\n");

#With parametrs
if (param()){
   my $name = param("name");
   my $password = param("password");
   if (goodpassword($name, $password)){
      my $url = param("url");
      $url =~ s/([^a-zA-Z0-9_%:@\/\-\.])/'%'.unpack("H2",$1)/ge;
      my $taskname = $url;
      $taskname =~ s/.*\///;
      my $logname = $taskname;
      $logname .= ".log";
      $logname = $logsdir."/".$logname;
      $taskname .= ".task";
      $taskname = $tasksdir."/".$taskname;
      open (TASK, ">$taskname");
      for ($i = 0; $i < $numbersoftry; $i++){
         print TASK "$url\n";
      }
      close(TASK);
      chdir($filesdir);
      my $output = `wget -b -c -i $taskname -a $logname`;
      if ($output =~ /pid/){
        chomp($output);
        $output =~ s/.*pid //;
	$output =~ s/\.//;
	open (TEMPLOG, ">>$logsdir/temp_log");
	flock(TEMPLOG, LOCK_EX);
	print TEMPLOG "$url $name $output\n";
	close(TEMPLOG);
        print("<meta HTTP-EQUIV=\"Refresh\" CONTENT=\"5;URL=progress.cgi\">\n");
        print("</HEAD>\n<BODY>\n"); 
        print("<H3>Downloading started. Now you go to page whith download statistic</H3>\n");
        print("<P><A HREF=\"progress.cgi\">Click here</A>, if you don't wont wait or browser don't go automatically...\n");	 
      }
      else{
         unlink($taskname);
	 print("</HEAD>\n<BODY>\n");
         print("<H2><font color=\"#ff0000\">Error</font> of Wget starting</H2>");
      }	  
   }
   else{
      print ("</HEAD>\n<BODY>\n");
      print("<H2><font color=\"#ff0000\">Error:</font> wrong login name or password</H2>");
   }
}

#Without parametrs
else{
   print ("<BODY>\n");
   print ("<H3 align=center><A HREF=\"http://irodov.nm.ru/wget4web/\">Wget4web</A>: Web interface for Wget</H3>\n"); 
   print ("<form method=\"post\" action=\"add.cgi\">\n");
   print ("<TABLE>\n");
   print ("<TR><TD>URL</TD><TD><input name=\"url\" type=text size=80><BR></TD></TR>\n");
   print ("<TR><TD><BR>Login</TD><TD><BR><input name=\"name\" type=text size=15></TD></TR>\n");
   print ("<TR><TD>Password&nbsp;</TD><TD><input name=\"password\" type=password size=15></TD></TR>\n");
   print ("</TABLE>\n");
   print ("<P><input type=submit value=\"Download\">&nbsp;&nbsp;<input type=reset value=\"Cancel\">\n</form>\n");
   
}

print end_html;
