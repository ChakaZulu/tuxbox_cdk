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

if ( $#ARGV >= 2 )
{
  if ( $ARGV[2] eq "version" )
  {
    $output = $_[1];
  }
  elsif ( $ARGV[2] eq "dir" )
  {
    $output = $_[2];
  }
  elsif ( $ARGV[2] eq "depend" )
  {
    @_ = split ( /:/, $_[3] );

    foreach ( @_ )
    {
      if ( $_ =~ m#\.tar\.(bz2|gz)# )
      {
        $output .= "Archive/" . $_ . " ";
      }
      elsif ( $_ =~ m#\.diff# )
      {
        $output .= "Patches/" . $_ . " ";
      }
      else
      {
        die "can't recognize type of archive " . $_;
      }
    }
  }
  elsif ( $ARGV[2] eq "prepare" )
  {
    shift @_; shift @_;

    my $dir = shift @_;

    shift @_;

    foreach ( @_ )
    {
      local @_;
      @_ = split ( /:/, $_ );

      if ( $output ne "" )
      {
        $output .= " && ";
      }

      if ( $_[0] eq "extract" )
      {
        if ( $_[1] =~ m#\.tar\.bz2# )
        {
          $output .= "bunzip2 -cd Archive/" . $_[1] . " | tar -x";
        }
        elsif ( $_[1] =~ m#\.tar\.gz# )
        {
          $output .= "gunzip -cd Archive/" . $_[1] . " | tar -x";
        }
        else
        {
          die "can't recognize type of archive " . $_[1];
        }
      }
      elsif ( $_[0] eq "dirextract" )
      {
        $output .= "( cd " . $dir . "; ";

        if ( $_[1] =~ m#\.tar\.bz2# )
        {
          $output .= "bunzip2 -cd ../Archive/" . $_[1] . " | tar -x";
        }
        elsif ( $_[1] =~ m#\.tar\.gz# )
        {
          $output .= "gunzip -cd ../Archive/" . $_[1] . " | tar -x";
        }
        else
        {
          die "can't recognize type of archive " . $_[1];
        }

        $output .= " )";
      }
      elsif ( $_[0] eq "patch" )
      {
        $output .= "( cd " . $dir . "; patch -p1 < ../Patches/" . $_[1] . " )";
      }
      elsif ( $_[0] eq "move" )
      {
        $output .= "mv " . $_[1] . " " . $_[2];
      }
      elsif ( $_[0] eq "remove" )
      {
        $output .= "( rm -rf " . $_[1] . " || /bin/true )";
      }
      elsif ( $_[0] eq "link" )
      {
        $output .= "( ln -s " . $_[1] . " " . $_[2] . " || /bin/true )";
      }
      else
      {
        die "can't recognise @_";
      }
    }
  }
  else
  {
    die "can't recognise " . $ARGV[2];
  }
}
else
{
  die;
}

print $output . "\n";
