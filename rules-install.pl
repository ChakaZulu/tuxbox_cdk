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
    $_ = shift ( @_ );

    if ( $output ne "" )
    {
      $output .= " && ";
    }

    if ( $_ eq "make" )
    {
      $output .= "\$\(MAKE\) " . join " ", @_;
    }
    elsif ( $_ eq "install" )
    {
      $output .= "\$\(INSTALL\) " . join " ", @_;
    }
    elsif ( $_ eq "move" )
    {
      $output .= "mv " . join " ", @_;
    }
    elsif ( $_ eq "remove" )
    {
      $output .= "rm -rf " . join " ", @_;
    }
    elsif ( $_ eq "link" )
    {
      $output .= "ln -sf " . join " ", @_;
    }
    elsif ( $_ eq "archive" )
    {
      $output .= "TARGETNAME-ar cru " . join " ", @_;
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

$output =~ s#TARGETNAME#\$\(target\)#g;
$output =~ s#TARGET#\$\(targetprefix\)#g;
$output =~ s#HOST#\$\(hostprefix\)#g;
$output =~ s#BUILD#\$\(buildprefix\)#g;

print $output . "\n";
