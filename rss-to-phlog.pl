#!/usr/bin/perl

use XML::Feed;
use LWP::Protocol::https;
use strict;
my $count;


#Options-----------------------------
  #URL for the RSS or ATOM feed:
  my $feed_url = "https://your.rss.feed.here";
  #Plog root (with trailing slash):
  my $root = "./test/";
  #Number of entries to pull at a time
  my $entry_count = 3;
  #Set to true to print some extra debug info
  my $debug = 1;
#------------------------------------

my $feed = XML::Feed->parse(URI->new($feed_url)) or die XML::Feed->errstr;
warn "Found feed titled ", $feed->title, ".\n" if $debug;

for my $entry ($feed->entries) {
  $count++;
  warn "found entry titled ", $entry->title, ".\n" if $debug;
  write_entry($entry->title, $entry->content->body, $entry->issued->ymd);  
  last if $count == $entry_count;
}

#Notes to myself
#$feed->entries returns an array containing XML::Feed::Entry objects.
#Those Entry objects then contain "Content" which are XML::Feed::Content objects. 
#It seems like a bit much, honestly, but the other xml parsing modules seem just as confusing. 


#Subroutines--------------------------

sub write_entry {
  my ($title,$content,$date) = @_; 
  $title =~ s/[<>:"\/\\'!|?* \(\)]//g; #Strip out stuff that shouldn't be in a filename
  # $title = substr($
  my $filename = $root.substr($date."_".$title, 0,36);
  if (! -e $filename) {
    open (PHLOG, '>',$filename) or die "failed to create file $filename\n"; warn "Opening $filename\n" if $debug; 
    print PHLOG strip_html($content); warn "Writing to  $filename\n" if $debug;
    close PHLOG; warn "Closing $filename\n" if $debug;
  } else {warn "Already found entry at $filename\n" if $debug}
}

sub strip_html {
  $_[0] =~ s/<img[^>]*?src\s*=\s*[""']?([^'"" >]+?)[ '""][^>]*?>/\(http link: $1\)/gi; #replace images with plain text addresses
  $_[0]=~ s/<br\s*\/?>/\n/gi; #replace HTML newlines with \n 
  $_[0] =~ s/<\/?([a-zA-Z]+)[^>]*>//gi; #strip any remaining HTML tags entirely.
  return $_[0];
}