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
    $head .= " \$(archivedir)/" . $file;
    $output .= "\$(archivedir)/" . $file . ":\n\tfalse || ";
    $output .= "mkdir -p \$(archivedir) && ( \\\n\t";
    shift @_;
    foreach ( @_ )
    {
      if ( $_ =~ m#^ftp://# )
      {
        $output .= "wget -c --passive-ftp -P \$(archivedir) " . $_ . "/" . $file . " || \\\n\t";
      }
      elsif ( $_ =~ m#^http://# )
      {
        $output .= "wget -t 2 -T 10 -c -P \$(archivedir) " . $_ . "/" . $file . " || \\\n\t";
      }
    }
    $output .= "wget -c -P \$(archivedir) http://www.dbox2-tuning.net/cvsdata/files/" . $file . " )";
    $output .= "\n\t\@touch \$\@";
    $output .= "\n\n";
  }
}

close ( RULES );

print $head . "\n\n" . $output . "\n";
