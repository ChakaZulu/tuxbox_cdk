#!/usr/bin/perl
use strict;

sub load
{
  open ( RULES, $_[0] ) or die;

  while ( <RULES> )
  {
    if ( ! m/^#/ )
    {
      chomp;
      @_ = split ( /;/, $_ );
      if ( $_[0] eq ">>>" )
      {
        close ( RULES );
        return load ( $_[1] );
      }
      elsif ( $_[0] eq $ARGV[1] )
      {
        close ( RULES );
        return @_;
      }
    }
  }

  close ( RULES );
  die "can't find package " . $ARGV[1];
}

@_ = &load ( $ARGV[0] );

my $output;

if ( $#ARGV >= 1 )
{
  shift @_;

  foreach ( @_ )
  {
    local @_;
    @_ = split ( /:/, $_ );

    if ( $output ne "" )
    {
      $output .= " && ";
    }

    if ( $_[0] eq "make" )
    {
      $output .= "make";
      shift @_;

      foreach ( @_ )
      {
        $output .= " " . $_;
      }
    }
    elsif ( $_[0] eq "install" )
    {
      $output .= "install";
      shift @_;

      foreach ( @_ )
      {
        $output .= " " . $_;
      }
    }
    elsif ( $_[0] eq "move" )
    {
      $output .= "mv " . $_[1] . " " . $_[2];
    }
    elsif ( $_[0] eq "remove" )
    {
      $output .= "rm -rf " . $_[1];
    }
    elsif ( $_[0] eq "link" )
    {
      $output .= "ln -sf " . $_[1] . " " . $_[2];
    }
    else
    {
      die "can't recognise @_";
    }
  }
}
else
{
  die;
}

$output =~ s#TARGET#\$\(targetprefix\)#g;
$output =~ s#HOST#\$\(hostprefix\)#g;
$output =~ s#BUILD#\$\(buildprefix\)#g;

print $output . "\n";
