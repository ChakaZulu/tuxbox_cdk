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
    $output .= "Archive/" . $_[0] . ":\n\twget -c -P Archive http://tuxbox.berlios.de/pub/tuxbox/cdk/src/" . $_[0];
    shift @_;
    foreach ( @_ )
    {
      if ( $_ =~ m#^ftp://# )
      {
        $output .= " || \\\n\twget -c --passive-ftp -P Archive " . $_ . "/" . $_[0];
      }
      elsif ( $_ =~ m#^http://# )
      {
        $output .= " || \\\n\twget -c --passive-ftp -P Archive " . $_ . "/" . $_[0];
      }
    }
    $output .= "\n\n";
  }
}

close ( RULES );

print $output . "\n";
