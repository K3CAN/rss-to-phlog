#!/usr/bin/perl

use XML::Feed;
use LWP::Protocol::https;
use strict;

#Options-----------------------------
  #URL for the RSS or ATOM feed:
  my $feed_url = "https://blog.k3can.us/index.php?feed/rss2";
  #Plog root:
  my $root = "";
  #Number of entries to pull at a time
  my $entry_count = 1;
  #Set to true to print some extra debug info
  my $debug = 1;
#------------------------------------

my $feed = XML::Feed->parse(URI->new($feed_url)) or die XML::Feed->errstr;
my $count;

warn "Found feed titled ", $feed->title, ".\n";

#Notes to myself
#$feed->entries returns an array containing XML::Feed::Entry objects.
#Those Entry objects then contain "Content" which are XML::Feed::Content objects. 
#It's a bit much, honestly, but the other xml parsing modules seem just as confusing. 


for my $entry ($feed->entries) {
  $count++;
  warn "found entry titled ", $entry->title, ".\n" if $debug;
  my $body = $entry->content->body;
  $body =~ s/<img[^>]*?src\s*=\s*[""']?([^'"" >]+?)[ '""][^>]*?>/\(http link: $1\)/gi; #replace images with plain text addresses
  $body =~ s/<br\s*\/?>/\n/gi; #replace HTML newlines with \n 
  $body =~ s/<\/?([a-zA-Z]+)[^>]*>//gi; #strip any remaining HTML tags entirely. 
  write_entry($entry->title, $entry->content->body, $entry->issued->ymd);  
  last if $count == $entry_count;
}

sub write_entry {
  my ($title,$content,$date) = @_; 
  $title =~ s/[<>:"\/\\'!|?*]//g; #Strip out stuff that shouldn't be in a filename
  $title =~ s/^\s+|\s+$//g; 
  my $filename = $root.$date."_".$title;
  if (! -e $filename) {
    open (PHLOG, '>',$filename) or die "failed to create file $filename\n"; warn "Opening $filename\n" if $debug; 
    print PHLOG $content; warn "Writing to  $filename\n" if $debug;
    close PHLOG; warn "Closing $filename\n" if $debug;
  } else {warn "Already found entry at $filename\n" if $debug}
}