#!/usr/bin/env perl

use strict;
use warnings;
use LWP::Simple;
use Config::Simple;
use XML::RSS::Parser;
use Net::Twitter::Lite;

# set path for your config file
my $cfg_file = '/home/hoge/.conf/config.ini';

my $cfg = new Config::Simple($cfg_file)->vars();
if ( !-f $cfg->{'lastfmToTwitter.local_mirror'} ) {
    mirror( $cfg->{'lastfm.myfeedurl'},
        $cfg->{'lastfmToTwitter.local_mirror'} );
}

my $parser    = XML::RSS::Parser->new;
my $prev_feed = $parser->parse_file( $cfg->{'lastfmToTwitter.local_mirror'} );
my $last_modified = $prev_feed->query('//item')->query('pubDate')->text_content;
mirror( $cfg->{'lastfm.myfeedurl'}, $cfg->{'lastfmToTwitter.local_mirror'} );
my $latest_feed = $parser->parse_file( $cfg->{'lastfmToTwitter.local_mirror'} );
my $pubulish_date =
  $latest_feed->query('//item')->query('pubDate')->text_content;
my $latest_tune = $latest_feed->query('//item')->query('title')->text_content;

if ( $pubulish_date eq $last_modified ) {
    die 'No update since latest publish';
}

my $twitter = Net::Twitter::Lite->new(
    username => $cfg->{'twitter.username'},
    password => $cfg->{'twitter.password'}
);

my $msg =
    $cfg->{'lastfmToTwitter.perfix'} . ' "'
  . $latest_tune . '" '
  . $cfg->{'lastfmToTwitter.suffix'};
$twitter->update($msg);

