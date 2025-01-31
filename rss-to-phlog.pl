#!/usr/bin/perl

use XML::Feed;
use LWP::Protocol::https;
use strict;
my $count;

# Note: Depending on the feed, this script may pull a large number of entries each time it 
# is run. You may be able to limit this by requesting a reduced feed via API or adjusting the feed
# settings if you control the feed.  

#Options-----------------------------
  #URL for the RSS or ATOM feed. Either pass from the command line or assign here:
  my $feed_url = defined($ARGV[0]) ? $ARGV[0] : "https://your.rss.feed.here";
  #Plog root (with trailing slash):
  my $phlogroot = "./test/";
  #Number of entries to review
  my $entry_count = 3;
#------------------------------------

my $feed = XML::Feed->parse(URI->new($feed_url)) or die XML::Feed->errstr;
warn "Found feed titled ", $feed->title, ".\n";

for my $entry ($feed->entries) {
  $count++;
  warn "$count: Found entry titled ", $entry->title, ".\n";
  write_entry($entry->title, $entry->content->body, $entry->issued->ymd,$phlogroot);  
  last if $count == $entry_count;
}

#Notes to myself
#$feed->entries returns an array containing XML::Feed::Entry objects.
#Those Entry objects then contain "Content" which are XML::Feed::Content objects. 


#Subroutines--------------------------

sub write_entry {
  my ($title,$content,$date,$root) = @_;
  my $filename = getfilename($title,$date,$root);
  $content = strip_html($content);
  if (-e $filename) {
    warn "\tEntry $title already exists\n";
    open (my $phlog, '<',$filename) or die "Found $filename but cannot open it\n";
    my $existing = do {local $/ = undef; <$phlog>};   #slurp in the file as a single string
    if ($content eq $existing) {                      #Could use a hash (MD5) here instead? 
      warn "\tNo changes to $title, skipping\n";
      close $phlog;
      return;
    }
    warn "\tUpdating contents of $title\n";
  }
    open (my $phlog, '>',$filename) or die "failed to create file $filename\n";
    print $phlog $content; warn "\tWriting to  $filename\n";
    close $phlog;
}

sub getfilename {
  my ($title,$date,$root) = @_; 
  $title =~ s/[<>:"\/\\'!|?* \(\)]//g; #Strip out stuff that shouldn't be in a filename
  return($root.substr($date."_".$title, 0,36));
}

#Consider replacing this with HTML::Strip? What about images? 
sub strip_html {        
  $_[0] =~ s/<img[^>]*?src\s*=\s*[""']?([^'"" >]+?)[ '""][^>]*?>/\(http link: $1\)/gi; #replace images with plain text addresses
  $_[0]=~ s/<br\s*\/?>/\n/gi; #replace HTML newlines with \n 
  $_[0] =~ s/<\/?([a-zA-Z]+)[^>]*>//gi; #strip any remaining HTML tags entirely.
  return $_[0];
}