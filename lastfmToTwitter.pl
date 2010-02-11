#!/usr/bin/env perl

use strict;
use warnings;
use LWP::Simple;
use Config::Simple;
use XML::RSS::Parser;
use Net::Twitter::Lite;

# set path for your config file
my $cfg_file = "$ENV{HOME}/.conf/config.ini";

if ( !-f $cfg_file ) {
    die 'No config file.';
}
my $cfg = new Config::Simple($cfg_file)->vars() or die Config::Simple->error();
my $lastfm_feedurl =
"http://ws.audioscrobbler.com/1.0/user/$cfg->{'lastfm.username'}/recenttracks.rss";
my $lastfm_mypage = "http://www.lastfm.jp/user/$cfg->{'lastfm.username'}";

if ( !-f $cfg->{'lastfmToTwitter.local_mirror'} ) {
    mirror( $lastfm_feedurl, $cfg->{'lastfmToTwitter.local_mirror'} );
}

if (mirror( $lastfm_feedurl, $cfg->{'lastfmToTwitter.local_mirror'} )==RC_NOT_MODIFIED){
    die 'No update since latest publish';
}
my $parser    = XML::RSS::Parser->new;
my $latest_feed = $parser->parse_file( $cfg->{'lastfmToTwitter.local_mirror'} );
my $latest_tune = $latest_feed->query('//item')->query('title')->text_content;

my $twitter = Net::Twitter::Lite->new(
    username => $cfg->{'twitter.username'},
    password => $cfg->{'twitter.password'}
);
my $msg =
"$cfg->{'lastfmToTwitter.prefix'} \"$latest_tune\" $cfg->{'lastfmToTwitter.suffix'}";
$twitter->update($msg);

