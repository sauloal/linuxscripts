#!/usr/bin/perl
# -*- perl -*-
#
#  Copyright (c) 1997, 2000, 2001 DJ Delorie, All Rights Reserved.  NO WARRANTEE.
#

#open(LOCK, ">/tmp/lock");
#flock(LOCK, 2);

if ($ARGV[0] eq "see-script") {
    print "Content-type: text/plain\n\n";
    open(IN, "lynxview.cgi");
    print while <IN>;
    exit 0;
}

# require "./common.pl";

# push(@INC, "/usr/local/etc/httpd/bin");
#push(@INC, split(':', $ENV{"PATH"}));
#require "cgi-lib.pl";
#&ReadParse;
use CGI;
CGI::ReadParse();

if ($in{'url'} !~ m@^http://([^\.]+\.)+[^\.]+@) {
    print "Content-type: text/html\n\n";
    print "Sorry, I can only handle http://<i>some.host</i>/ URLs.\n";
    print "You typed in `<tt>$in{'url'}</tt>'.\n";
    exit 0;
}

$in{'url'} =~ tr/'//d;

$in{'url'} .= "/" unless $in{'url'} =~ m@http://.*/@;
($urlhead,$urlpath) = $in{'url'} =~ m@([^/]+/+[^/]+)(.*)@;
$urlpath =~ s@/[^/]+$@/@;
$urlpath = "/" unless $urlpath;

$me = "lynxview.cgi?url=";

print "Content-type: text/html\n\n";

print "<title>LynxView: $in{'url'}</title><center>\n";

print "<form method=\"GET\" action=\"lynxview.cgi\">\n";
print "<br><small><a href=\"lynxview.html\">Lynx Viewer</a>\n";
print "Lynx Viewer: <input name=url value=\"$in{'url'}\" size=80>\n";
print "<i>This service is intended to be used only by content developers, on their own pages.</i>\n";
print "<hr noshade size=2></small></form></center>\n";

open(L, "lynx -force_html -dump -underscore '$in{'url'}' 2>&1 |");
#open(L, "links -dump '$in{'url'}' 2>&1 |");
#open(L, "w3m -dump '$in{'url'}' 2>&1 |");
print "<pre>";
while (<L>) {
    while (m@<a\s*\n@) {
	$line = <L>;
	last unless $line;
	$_ .= $line;
	s/<a\s*(\n\s*)/$1<a /g;
    }
    if (m@<a href="[^>"]+\n@) {
	s/\s+\n$//;
	$line = <L>;
	last unless $line;
	$q = $line;
	$q =~ s/^\s+//;
	$_ .= $q;
    }
    0 while s/<a href="([^\"]+)">/&fixurl($1)/ge;
    0 while s@ +</a>@</a> @g;
    print;
}
close(L);
exit 0;


sub fixurl {
    local ($q) = @_;
    $q =~ s/[\r\n]//;
    $q =~ s/%0a//;
    return "<A href=\"" . &rebase_url(undef, $q) . "\">";
}

