#!/usr/bin/perl -w
use strict;
use Cwd;
#use VideoLan::Client;

# setup
my $host       = "127.0.0.1";
my $port       = "2121";
my $passwd     = "XXXXXX";
my $folder     = "/share/mnt/jean_mp3/MP3";
my $tmpFolder  = ".";
my $ttl        = 12;
my $cache      = 3000;
my $streamAdd  = "0.0.0.0:2020";
my $interface  = "rc"; # none, http, rc, telnet
my $httpAdd    = "127.0.0.1:2121";
my $rcAdd      = "127.0.0.1:2121";
my $telnetIp   = "127.0.0.1";
my $telnetPort = "2121";
my $telnetPwd  = "XXXXXX";
my $cwd        = getcwd;
$tmpFolder     = $cwd;
my $playlist   = "$tmpFolder/playlist.m3u";
my $logFile    = "$tmpFolder/vlcstream.log";
my $serverLog  = "$tmpFolder/vlcserver.log";
my $findCmd    = "find $folder/ -iname '*.mp3' | sort -R | sort -R > $playlist";
my $reFind     = 1;
my $killAllCmd = "killall vlc 1>/dev/null 2>/dev/null";
my $processes  = "pgrep -x vlc";
my $process    = `$processes`;
my $isRunning  = $process ? 1 : 0;
my @options    = qw (play pause stop next prev status info stats get_time get_title get_length);
my %options;
map { $options{$_} = 1 } @options;
$options{"on"}  = 1;
$options{"off"} = 1;
$options{"log"} = 1;

my $vlc_interface_cmd   = "";
my $vlc_interface_cmd_I = "-I $interface";
if ($interface ne "none")
{
	if ($interface eq "rc")     { $vlc_interface_cmd .= " --rc-host $rcAdd"};
	if ($interface eq "http")   { $vlc_interface_cmd .= " --http-host $httpAdd"};
	if ($interface eq "telnet") { $vlc_interface_cmd .= " --telnet-host $telnetIp --telnet-port $telnetPort --telnet-password $telnetPwd"};
}

my $vlc_opt_cmd     = "--sout-keep --ttl $ttl --random"; # --daemon
my $vlc_cache_cmd   = "--file-caching $cache --sout-mux-caching $cache";
my $vlc_dest_cmd    = "--sout-standard-dst $streamAdd";
my $vlc_sout_cmd    = "--sout '#std{access=http,mux=raw}'";
my $vlc_logging_cmd = "1>>$logFile 2>>$logFile";
my $vlc_run_cmd     = "cvlc $vlc_interface_cmd_I $playlist $vlc_interface_cmd $vlc_opt_cmd $vlc_cache_cmd $vlc_dest_cmd $vlc_sout_cmd $vlc_logging_cmd &";



my $script_name = $ENV{"SCRIPT_NAME"} || $0;

#html
my $method = "POST";
&header(); # cabecalho HTML
my $nfo = &getform(); # obtem os dados enviados pelo formulario
&getOnOff($isRunning);

if ($isRunning)
{
	my $buttons = &getOptions();
	print $buttons;
}

&answerquery($nfo); # se houve texto submetido... coloque um formulario preenchido
&foot(); # coloca o rodape do HTML





sub getOnOff
{
	my $currentState = $_[0];

	my $onB = $currentState ? " disabled=\"disabled\"" : "";
	my $ofB = $currentState ? ""                       : " disabled=\"disabled\"";

	print "
					<tr>
						<td align=\"center\">
							<b><input type=\"submit\" value=\"on\"  name=\"on\"  tabindex=\"0\"$onB></b>
							<b><input type=\"submit\" value=\"off\" name=\"off\" tabindex=\"1\"$ofB></b>
						</td>
					</tr>";
}


sub getOptions
{
	#| play . . . . . . . . . . . . . . . . . . play stream
	#| stop . . . . . . . . . . . . . . . . . . stop stream
	#| next . . . . . . . . . . . . . .  next playlist item
	#| prev . . . . . . . . . . . .  previous playlist item
	#| status . . . . . . . . . . . current playlist status
	#| pause  . . . . . . . . . . . . . . . .  toggle pause
	#| info . . . . .  information about the current stream
	#| stats  . . . . . . . .  show statistical information
	#| get_time . . seconds elapsed since stream's beginning
	#| is_playing . . . .  1 if a stream plays, 0 otherwise
	#| get_title . . . . .  the title of the current stream
	#| get_length . . . .  the length of the current stream
	my $options = "";

	my $is_playing = &sendCommand("is_playing");
	#is_playing

	for (my $opt = 0; $opt < @options; $opt++)
	{
		$options .= "\t"x8 . "<b><input type=\"submit\" value=\"".$options[$opt]."\" name=\"".$options[$opt]."\" tabindex=\"".($opt+2)."\"></b>\n";
		if ($opt == (int(@options/2))) { $options .= "\n". "\t"x8 . "<br>\n"; };
	} 

	my $buttons = "
					<tr>
						<td>
							<center>
								<b>SEND YOUR COMMAND</b><br/>
								 [ IS PLAYING :: $is_playing ] 
							</center>
						</td>
					</tr>
					<tr>
						<td>
							<center>
$options
							</center>
						</td>
					</tr>
";

	return $buttons;
}




sub sendCommand
{
	my $command = $_[0];

#	my $vlc          = VideoLan::Client->new( HOST =>"$host", PORT => "$port", PASSWD => "$passwd");
#	my $loginResult  = $vlc->login();
#	my @command      = $vlc->cmd("control $command");
#	my $logoutResult = $vlc->logout();

	#print "SENDING COMMAND $command\n";
	#(echo -e "\nget_title\n"; sleep 1; echo -e "\nlogout\n") | telnet 127.0.0.1 2121 2>&1

	my $result = "NO QUERY";

	if (( $command eq "on" ) && ( ! $isRunning ))
	{
		#start
		$result = "ON | " . &turnOn();;
	}
	elsif (( $command eq "off" ) && ( $isRunning ))
	{
		#stop
		$result = "OFF | " . &turnOff();
	}
	elsif ( $command eq "log" )
	{
		#stop
		$result = "LOG | " . &checkLog();
	}
	elsif (( $isRunning ) && ( $command ne "on" ) && ( $command ne "off" ))
	{
		my $exe    = "(echo -e \"\\n$command\\n\"; sleep 4; echo -e \"\\nlogout\\n\") | telnet $host $port 2>/dev/null";
		#print "EXE $exe\n";
		$result = `$exe`;
		#print "RESULT $result\n";
		if ( index($result, "Conected") == -1 )
		{
			$result = "ERROR CONNECTING. TRY AGAIN OR RESTART VLC.";
		}
		else
		{
			my $pos = index($result, "\^]");
			$result = substr($result, ($pos + 6));
		}
		chomp $result;
	}

	return $result;
}


sub checkLog
{
	my $result = "PROGRAM ::\n";
	if ( -f $logFile )
	{
		$result = `tail -30 $logFile`;
	} else {
		$result = "NO PROGRAM LOGFILE $logFile";
	}

	$result .= "SERVER ::\n";
	if ( -f $serverLog )
	{
		$result .= `tail -30 $serverLog`;
	} else {
		$result .= "NO SERVER LOGFILE $serverLog";
	}

	return $result;
}


sub turnOn
{
	open SRV, ">>$serverLog";

	print SRV time, " ON :: CURRENT\n",`ps aux | grep vlc`,"\n";

	if ( ! -f $playlist )
	{
		`$findCmd`;
	}

	print SRV time, " ON :: TOTAL MUSICS\n", `wc -l $playlist`, "\n";
	print SRV time, " ON :: KILLING\n$killAllCmd\n", `$killAllCmd`, "\n";
	sleep 3;
	my $result = `$vlc_run_cmd`;
	chomp $result;
	print SRV time, " ON :: RUNNING\n$vlc_run_cmd\n",`ps aux | grep vlc`,"\n";
	sleep 2;
	close SRV;

	return $result;
}


sub turnOff
{
	open SRV, ">>$serverLog";
	print SRV time, " OFF :: KILLING COMMAND\n$killAllCmd\n", `$killAllCmd`, "\n";
	sleep 2;
	print SRV time, " OFF :: KILLING RESULT \n$killAllCmd\n", `ps aux | grep vlc`, "\n";
	close SRV;
	return "KILLED";
}

###############################################################
######### OBTEM OS DADOS ENVIADOS PELO FORMULARIO #############
###############################################################
sub getform
{
	my $buffer = "";
	my %info;

	if ((exists $ENV{"REQUEST_METHOD"}) || (exists $ENV{'CONTENT_LENGTH'}))
	{
		if ($ENV{"REQUEST_METHOD"} eq 'GET')
		{
			$buffer = $ENV{'QUERY_STRING'}
		} else { 
			read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'}) 
		};
	} else {
		$buffer = $ARGV[0] || "";
	};

	#if ($ENV{"REQUEST_METHOD"} eq 'GET') { print "get funcionou" } else { print "post" };

	my @values = split /&/, $buffer;
	#print "@values";
	foreach my $pair (@values)
	{
		my ($command, $value) = split /=/, $pair;
		if ((defined $value) && ($options{$command}))
		{
			$value =~ tr/+/ /;
			$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
			chomp ($value);
		}
		$info{$command} = $value || 1;
	};

	return \%info;
} # end of getting commands from URL



###############################################################
############# IMPRIME O FORMULARIO HTML VAZIO #################
###############################################################
sub answerquery {
	my $info = $_[0];

	if (scalar(keys %$info))
	{
		foreach my $key (keys %$info)
		{
			#print "COMMAND COMMING IN $key\n";
			my $result = &sendCommand($key);
			print "
					<tr>
						<td>last command: \"$key\" || result: <pre>\"$result\"</pre></td>
					</tr>
";
		}
	} else {
		#print "NO COMMANDS COMMING IN\n";
	}
}

###############################################################
################# IMPRIME O CABECALHO HTML ####################
###############################################################
sub header {

my $TITLE = "VLC CONTROL";
print "Content-type: text/html\n\n";
print <<HTML

<html>
	<head>
		<meta http-equiv="Content-Language" content="pt-br">
		<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
		<title>$TITLE</title>
	</head>
	<body bgcolor="EEEEEE" text="black" link="#FFFFFF" vlink="#FF0000" alink="#FFFF00">
		<center>
			<form method=GET action=$script_name>
				<table border="1" bordercolor="black" cellpadding="0" cellspacing="0" align="center" width="600">
					<tr bgcolor="black">
						<td align="center">
							<font size="5" face="verdana" color="white">
								<b>$TITLE</b>
							</font>
						</td>
					</tr>
					<tr>
						<td align=\"right\">
							<a href=\"$0\">home</a>
						</td>
					</tr>
HTML
;
}


###############################################################
################### IMPRIME O RODAPE HTML #####################
###############################################################
sub foot {
print <<HTML

					<br>
					<tr bgcolor="black">
						<td align="right">
							<small>
								<font size="2" face="verdana" color="white">
									VLC CONTROL by Saulo 02/2010
									<br/>
									FIND: $findCmd
									<br/>
									RUN: $vlc_run_cmd
									<br/>
									KILL: $killAllCmd
									<br/>
									IS RUNNING: $isRunning ($process)
									<br/>
									<b><input type="submit" value="log" name="log"></b>
								</font>
							</small>
						</td>
					</tr>
				</table>
			</form>
		</center>
	</body>
</html>
HTML
;
}



1;


#http://search.cpan.org/~elliryc/VideoLan-Client-0.11/lib/VideoLan/Client.pm
# login - Initiate the connection with vlc
#    $val = $ojb->login;
#    If succed return 1, else return 0.
# logout - Close the connection with vlc
#    $obj->logout;
# shutdown - Stop the vlc and close the connection.
#    $obj->shutdown;
# cmd - lauchn a command to vlc and return the output
#    @val = $obj->cmd('commande');
# add_broadcast_media - add a broadcast media to vlc
#    $obj->add_broadcast_media($name,$input,$output);
#    input and output use the syntaxe of vlc input/output
# load_config_file - load on config file in vlc
#    $obj->load_config_file($file)
# save_config_file - save the running config on a file
#    $obj->save_config_file($file)
# media_play - Play a media
#    $obj->media_play($name)
# media_stop - Stop playing a media
#    $obj->media_stop($name)
# launchvlc - lauchn a vlc with telnet interface
#    $val = lauchnvlc;
#    Work only if the host is localhost. Will only work on *NIX where nohup 
#    commande exist and vlc command is in path. lauchnvlc method is not support actually, just in test.




# http://www.videolan.org/doc/streaming-howto/en/ch05.html
#help : Displays an exhaustive command lines list
#new (name) vod|broadcast|schedule [properties] : Create a new vod, broadcast or schedule element. 
#      Element names must be unique and cannot be "media" or "schedule". 
#      You can specify properties in this command line or later on by using the setup command.
#setup (name) (properties) : Set an elements property. See Media Properties.
#show [(name)|media|schedule] : Display current element states and configurations.
#      show (name) - Specify an element's name to show all information concerning this element.
#      show media displays a summary of media states.
#      show schedule displays a summary of schedule states.
#del (name)|all|media|schedule : Delete an element or a group of elements. 
#      If the element wasn't stopped, it is first stopped before being deleted.
#del (name) - Delete the (name) element.
#del all - Delete all elements
#del media - Delete all media elements.
#del schedule - Delete all schedule elements
#control (name) [instance_name] (command) : Change the state of the (instance_name) instance of the (name) media. 
#       If (instance_name) isn't specified, the control command affects the default instance. 
#       See Control Commands for available control commands.
#       Control Commands
#         play  : Stat a broadcast media. The media begins to launch the first item of the input list, 
#                 then launches the next one and so on. (like a play list)
#         pause : Put the broadcast media in paused status.
#         stop  : Stop the broadcast media.
#         seek (percentage) : Seek in the current playing item of the input list.
#save (config_file) : Save all media and schedule configurations in the specified config file. 
#       The config file path is relative to the directory in which vlc was launched. If the file exists it will be overwritten. 
#       Note that states, such as playing, paused or stop, are not saved. See Configuration Files for more info.
#load (config_file) : Load a configuration file. The config file path is relative to the 
#       directory in which vlc was launched. See Configuration Files for more info.



#+----[ Remote control commands ]
#| 
#| add XYZ  . . . . . . . . . . . . add XYZ to playlist
#| enqueue XYZ  . . . . . . . . . queue XYZ to playlist
#| playlist . . . . .  show items currently in playlist
#| play . . . . . . . . . . . . . . . . . . play stream
#| stop . . . . . . . . . . . . . . . . . . stop stream
#| next . . . . . . . . . . . . . .  next playlist item
#| prev . . . . . . . . . . . .  previous playlist item
#| goto . . . . . . . . . . . . . .  goto item at index
#| repeat [on|off] . . . .  toggle playlist item repeat
#| loop [on|off] . . . . . . . . . toggle playlist loop
#| random [on|off] . . . . . . .  toggle random jumping
#| clear . . . . . . . . . . . . . . clear the playlist
#| status . . . . . . . . . . . current playlist status
#| title [X]  . . . . . . set/get title in current item
#| title_n  . . . . . . . .  next title in current item
#| title_p  . . . . . .  previous title in current item
#| chapter [X]  . . . . set/get chapter in current item
#| chapter_n  . . . . . .  next chapter in current item
#| chapter_p  . . . .  previous chapter in current item
#| 
#| seek X . . . seek in seconds, for instance `seek 12'
#| pause  . . . . . . . . . . . . . . . .  toggle pause
#| fastforward  . . . . . . . .  .  set to maximum rate
#| rewind  . . . . . . . . . . . .  set to minimum rate
#| faster . . . . . . . . . .  faster playing of stream
#| slower . . . . . . . . . .  slower playing of stream
#| normal . . . . . . . . . .  normal playing of stream
#| f [on|off] . . . . . . . . . . . . toggle fullscreen
#| info . . . . .  information about the current stream
#| stats  . . . . . . . .  show statistical information
#| get_time . . seconds elapsed since stream's beginning
#| is_playing . . . .  1 if a stream plays, 0 otherwise
#| get_title . . . . .  the title of the current stream
#| get_length . . . .  the length of the current stream
#| 
#| volume [X] . . . . . . . . . .  set/get audio volume
#| volup [X]  . . . . . . .  raise audio volume X steps
#| voldown [X]  . . . . . .  lower audio volume X steps
#| adev [X] . . . . . . . . . . .  set/get audio device
#| achan [X]. . . . . . . . . .  set/get audio channels
#| atrack [X] . . . . . . . . . . . set/get audio track
#| vtrack [X] . . . . . . . . . . . set/get video track
#| vratio [X]  . . . . . . . set/get video aspect ratio
#| vcrop [X]  . . . . . . . . . . .  set/get video crop
#| vzoom [X]  . . . . . . . . . . .  set/get video zoom
#| snapshot . . . . . . . . . . . . take video snapshot
#| strack [X] . . . . . . . . . set/get subtitles track
#| key [hotkey name] . . . . . .  simulate hotkey press
#| menu . . [on|off|up|down|left|right|select] use menu
#| 
#| help . . . . . . . . . . . . . . . this help message
#| longhelp . . . . . . . . . . . a longer help message
#| logout . . . . . . .  exit (if in socket connection)
#| quit . . . . . . . . . . . . . . . . . . .  quit vlc
#| 
#+----[ end of help ]


