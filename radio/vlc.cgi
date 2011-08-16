#!/usr/bin/perl -w
use strict;
#use VideoLan::Client;

# setup
my $host   = "127.0.0.1";
my $port   = "2121";
my $passwd = "XXXXXX";
my $script_name = $ENV{"SCRIPT_NAME"} || $0;

#html
my $method = "POST";
&header(); # cabecalho HTML
&getform(); # obtem os dados enviados pelo formulario
&foot(); # coloca o rodape do HTML




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


sub sendCommand
{
    my $command = $_[0];

#   my $vlc          = VideoLan::Client->new( HOST =>"$host", PORT => "$port", PASSWD => "$passwd");
#   my $loginResult  = $vlc->login();
#   my @command      = $vlc->cmd("control $command");
#   my $logoutResult = $vlc->logout();

    #print "SENDING COMMAND $command\n";
    #(echo -e "\nget_title\n"; sleep 1; echo -e "\nlogout\n") | telnet 127.0.0.1 2121 2>&1
    my $exe    = "(echo -e \"\\n$command\\n\"; sleep 3; echo -e \"\\nlogout\\n\") | telnet $host $port 2>/dev/null";
    #print "EXE $exe\n";
    my $result = `$exe`;
    #print "RESULT $result\n";
    if (index($result, "Conected") != -1)
    {
        $result = "ERROR CONNECTING";
    }
    else
    {
        $result = substr($result, (index($result, "\^]")+6));
    }
    chomp $result;
    return $result;
}


###############################################################
######### OBTEM OS DADOS ENVIADOS PELO FORMULARIO #############
###############################################################
sub getform{
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
        if (defined $value)
        {
            $value =~ tr/+/ /;
            $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
            chomp ($value);
        }
        $info{$command} = $value || 1;
    };

    &answerquery(\%info) # se houve texto submetido... coloque um formulario preenchido
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
my @options = qw (play pause stop next prev status info stats is_playing get_time get_title get_length);
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

for (my $opt = 0; $opt < @options; $opt++)
{
    $options .= "\t"x8 . "<b><input type=\"submit\" value=\"".$options[$opt]."\" name=\"".$options[$opt]."\" tabindex=\"$opt\"></b>\n";
    if ($opt == (int((@options/2)+.5))) { $options .= "\n". "\t"x8 . "<br>\n"; };
} 

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
                <table border="1" bordercolor="black" cellpadding="0" cellspacing="0" align="center">
                    <tr bgcolor="black">
                        <td align="center">
                            <font size="5" face="verdana" color="white">
                                <b>$TITLE</b>
                            </font>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <center>
                                <b>SEND YOUR COMMAND</b>
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
