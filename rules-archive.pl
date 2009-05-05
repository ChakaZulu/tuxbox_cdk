#!/usr/bin/perl
use strict;

my $head = "download:";
my $output;

open ( RULES, $ARGV[0] ) or die;

while ( <RULES> )
{
  chomp;
  if ( ! m/^#/ and ! m/^\s*$/ )
  {
    @_ = split ( /;/, $_ );
    my $file = $_[0];
    $head .= " Archive/" . $file;
    $output .= "Archive/" . $file . ":\n\tfalse";
    shift @_;
    foreach ( @_ )
    {
      if ( $_ =~ m#^ftp://# )
      {
        $output .= " || \\\n\twget -c --passive-ftp -P Archive " . $_ . "/" . $file;
      }
      elsif ( $_ =~ m#^http://# )
      {
        $output .= " || \\\n\twget -c -P Archive " . $_ . "/" . $file;
      }
    }
    $output .= " || \\\n\twget -c -P Archive http://www.dbox2-tuning.net/cvsdata/files/" . $file;
    $output .= "\n\t\@touch \$\@";
    $output .= "\n\n";
  }
}

close ( RULES );

print $head . "\n\n" . $output . "\n";
