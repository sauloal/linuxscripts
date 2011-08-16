#!/usr/bin/perl -w
use strict;
#http://search.cpan.org/~mmims/Net-Twitter/lib/Net/Twitter.pod
#http://search.cpan.org/dist/Net-Twitter/lib/Net/Twitter/Role/OAuth.pm
#twitter voice talk say time read uri_escape_RFC3986 url oauth
use strict;
use Net::Twitter;
use Scalar::Util 'blessed';

my $list_total             = 50;
my $verbose                = 0;

my $consumer_key           = '';
my $consumer_secret        = '';
my $access_tolken          = '';
my $access_tolken_secret   = '';



my $nt = Net::Twitter->new(
      traits              => ['API::REST', 'OAuth'],
      consumer_key        => $consumer_key,
      consumer_secret     => $consumer_secret,
      access_token        => $access_tolken,
      access_token_secret => $access_tolken_secret,
  );

if ( @ARGV )
{
    &tweet(join(' ', @ARGV));
} else {
    &read();
}

sub read
{
    eval {
        #my $statuses = $nt->friends_timeline({ since_id => '', count => 100 });
        my $statuses = $nt->friends_timeline({ count => $list_total });
        #my $statuses = $nt->friends_timeline({ page => 2 });
        my $count = 0;
        for my $status ( @$statuses )
        {
              $count++;

              my $created          = $status->{created_at};
              my $text             = $status->{text};
              my $user             = $status->{user};
              my $id               = $status->{id};
              my $user_id          = $user->{id};
              my $user_screen_name = $user->{screen_name};
              my $user_created_at  = $user->{created_at};
              print "$count :: $created [$id] :: <$user_screen_name> $text\n";
              if ( $verbose )
              {
                  map { print $count, " : ", $_, " => ", ( ( defined $status->{$_} ) ? $status->{$_} : 'undef' ), "\n"; } sort keys %$status;
                  map { print $count, " : USER : ", $_, " => ", $user->{$_}, "\n" } sort keys %$user;
                  print "\n";
              }
        } # end for my status
    };
    if ( my $err = $@ ) {
        die $@ unless blessed $err && $err->isa('Net::Twitter::Error');

        warn "   HTTP Response Code: ", $err->code,    "\n",
             "   HTTP Message......: ", $err->message, "\n",
             "   Twitter error.....: ", $err->error,   "\n";
    }
}

sub tweet
{
    my $msg = $_[0];
    print "TWITTERING \"$msg\"\n";

    eval {
        my $res              = $nt->update($msg);
        my $created          = $res->{created_at};
        my $id               = $res->{id};
        my $text             = $res->{text};
        my $user             = $res->{user};
        my $truncated        = $res->{truncated};
        my $user_screen_name = $user->{screen_name};
        my $user_created_at  = $user->{created_at};
        my $user_id          = $user->{id};

        if ( $verbose )
        {
            print "RESULT:\n";
            map { print " $_ => ",  (( defined $res->{$_} ) ? $res->{$_} : 'undef' ), "\n" } sort keys %$res;
        }
    }; # end eval
    if ( my $err = $@ ) {
        die $@ unless blessed $err && $err->isa('Net::Twitter::Error');

        warn "   HTTP Response Code: ", $err->code,    "\n",
             "   HTTP Message......: ", $err->message, "\n",
             "   Twitter error.....: ", $err->error,   "\n";
    }
}

sub tweetReply
{
    my $rep_id = $_[0];
    my $msg    = $_[1];
    print "TWITTERING \"$msg\" IN REPLY TO \"$rep_id\"\n";


    eval {
        my $res              = $nt->update($msg, { in_reply_to_status_id => $rep_id });
        my $created          = $res->{created_at};
        my $id               = $res->{id};
        my $text             = $res->{text};
        my $user             = $res->{user};
        my $truncated        = $res->{truncated};
        my $user_screen_name = $user->{screen_name};
        my $user_created_at  = $user->{created_at};
        my $user_id          = $user->{id};

        if ( $verbose )
        {
            print "RESULT:\n";
            map { print " $_ => ",  (( defined $res->{$_} ) ? $res->{$_} : 'undef' ), "\n" } sort keys %$res;
        }
    }; # end eval
    if ( my $err = $@ ) {
        die $@ unless blessed $err && $err->isa('Net::Twitter::Error');

        warn "   HTTP Response Code: ", $err->code,    "\n",
             "   HTTP Message......: ", $err->message, "\n",
             "   Twitter error.....: ", $err->error,   "\n";
    }
}

1;
