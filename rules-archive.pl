#!/usr/bin/perl
use strict;

my $output;

open ( RULES, $ARGV[0] ) or die;

while ( <RULES> )
{
  chomp;
  if ( ! m/^#/ and ! m/^\s*$/ )
  {
    @_ = split ( /;/, $_ );
    my $file = $_[0];
    $output .= "Archive/" . $file . ":\n\twget -c -P Archive http://tuxbox.berlios.de/pub/tuxbox/cdk/src/" . $file;
    shift @_;
    foreach ( @_ )
    {
      if ( $_ =~ m#^ftp://# )
      {
        $output .= " || \\\n\twget -c --passive-ftp -P Archive " . $_ . "/" . $file;
      }
      elsif ( $_ =~ m#^http://# )
      {
        $output .= " || \\\n\twget -c --passive-ftp -P Archive " . $_ . "/" . $file;
      }
    }
    $output .= "\n\n";
  }
}

close ( RULES );

print $output . "\n";
