#!/usr/bin/perl -w

# "Copyright (c) 2000-2002 The Regents of the University of California.  
# All rights reserved.
# 
# Permission to use, copy, modify, and distribute this software and its
# documentation for any purpose, without fee, and without written agreement is
# hereby granted, provided that the above copyright notice, the following
# two paragraphs and the author appear in all copies of this software.
# 
# IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
# DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
# OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF
# CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 
# THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
# ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
# PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS."

# Authors: Cory Sharp
# $Id: create_Config.pl,v 1.7 2003/08/19 06:28:44 cssharp Exp $

use strict;

use FindBin;
use lib $FindBin::Bin;
use FindInclude;
use SlurpFile;


my %sources = ();
my %exts = ();
my @wiring = ();

my $G_warning =<< 'EOF';
// *** WARNING ****** WARNING ****** WARNING ****** WARNING ****** WARNING ***
// ***                                                                     ***
// *** This file was automatically generated by create_Config.pl.          ***
// *** Any and all changes made to this file WILL BE LOST!                 ***
// ***                                                                     ***
// *** WARNING ****** WARNING ****** WARNING ****** WARNING ****** WARNING ***

EOF

@ARGV = &FindInclude::parse_include_opts( @ARGV );
map { chomp; $sources{$_} = 1 } <>;

# process those filenames for the special lines
for my $file (sort keys %sources) {
  my $text = &SlurpFile::slurp_file( $file );

  my @configs = grep { /^\s*\/\/!!\s*Config\b/ } split( /\n/, $text );
  for my $config (@configs) {
    if( $config =~ /(\d+)\s*\{\s*([^;=]*[^;=\s])\s+(\w+)(?:\s*=\s*([^;]+))?\s*;\s*\}\s*$/ ) {
      $exts{$3} = { confignum => $1, type => $2, name => $3, init => $4 };
    } else {
      print STDERR "WARNING, malformed Config line:\n  > $config\n";
    }
  }

  $text = &SlurpFile::scrub_c_comments( $text );

  my $module = join( " ", $text =~ /\bmodule\s+(\w+)\s*\{/ );
  my $uses = join( " ", $text =~ /\buses(\s*\{[^\}]*\}|[^;]*;)/g );
  my @interfaces = ($uses =~ /\binterface\s+(Config_\w+)\s*;/g);

  if( $module && @interfaces ) {
    for (@interfaces) {
      push( @wiring, { module => $module, interface => $_ } );
    }
  }
}

# make build/
my $dir = "build";
mkdir $dir unless -d $dir;

create_config_header( "build", \%exts );
create_config_module( "build", \%exts );
create_config_configuration( "build", \%exts, \@wiring );
for my $ext (sort keys %exts) {
  create_config_interface( "build", $exts{$ext} );
}


sub filter_nesc {
  my ($infile,$outfile,$subs) = @_;
  my $file = &FindInclude::find_file( $infile );
  die "ERROR, could not find $infile, aborting.\n" unless defined $file;
  my $text = &SlurpFile::scrub_c_comments( &SlurpFile::slurp_file( $file ) );
  $text =~ s/^\s+//;
  my $err = "";
  $text =~ s/\$\{(\w+)\}(?:\s*?\n)?/
             $err.="$file: unknown Neighbor variable $1\n" unless defined $subs->{$1};
	     $subs->{$1}
	    /eg;
  die "${err}ERROR, unknown variables, aborting.\n" if $err;
  &SlurpFile::dump_file( $outfile, "$G_warning$text" );
  1;
}


sub create_config_header {
  my ($dir,$exts) = @_;
  $dir .= "/" unless $dir =~ m/\/$/;
  my %subs = ( fields => "", inits => "", enums => "" );
  for my $ee (sort keys %{$exts}) {
    $subs{fields} .= "  $exts->{$ee}->{type} $exts->{$ee}->{name};\n";
    $subs{inits} .= "  $exts->{$ee}->{name} : $exts->{$ee}->{init},\n"
      if defined($exts{$ee}->{init}) && length($exts{$ee}->{init});
    $subs{enums} .= "  CONFIG_$exts->{$ee}->{name} = $exts->{$ee}->{confignum},\n";
  }
  $subs{enums} .= "  CONFIG_needs_at_least_one_enum = 0,\n" if $subs{enums} eq "";
  my $filename = "${dir}Config.h";
  print STDERR "    creating $filename\n";
  filter_nesc( "Config.config.h", $filename, \%subs );
}


sub create_config_interface {
  my ($dir, $ext) = @_;
  $dir .= "/" unless $dir =~ m/\/$/;
  my $type = $ext->{type};
  my $name = $ext->{name};
  my $filename = "${dir}Config_${name}.nc";
  my $text =<< "EOF";
$G_warning
interface Config_$name
{
  event void updated();
  command result_t set( $type $name );
}

EOF
  print STDERR "    creating $filename\n";
  &SlurpFile::dump_file( $filename, $text );
}


sub create_config_module {
  my ($dir, $exts) = @_;
  $dir .= "/" unless $dir =~ m/\/$/;

  my %subs = (
    provides => "",
    receive_cases => "",
    query_cases => "",
    config_funcs => "",
  );

  for my $ee (sort keys %{$exts}) {

    my $type = $exts->{$ee}->{type};
    my $name = $exts->{$ee}->{name};
    my $case = "case CONFIG_$name:";

    $subs{provides} .= "    interface Config_$name;\n";

    $subs{receive_cases} .= <<"EOF";
      $case
        if( (msgdata = popFromRoutingMsg( msg, sizeof($type) )) == 0 )
	  return msg;
	call Config_$name.set( *($type*)msgdata );
	break;

EOF

    $subs{query_cases} .= << "EOF";
      $case
        if( (msgdata = pushToRoutingMsg( msg, sizeof($type) )) != 0 )
	{
	  *($type*)msgdata = G_Config.$name;
	  bSend = TRUE;
	}
	break;
	
EOF

    $subs{config_funcs} .= <<"EOF";
  command result_t Config_$name.set( $type val )
  {
    // if( val == G_Config.$name ) return FAIL;
    G_Config.$name = val;
    signal Config_$name.updated();
    return SUCCESS;
  }

  default event void Config_$name.updated()
  {
  }


EOF
  }

  my $filename = "${dir}ConfigM.nc";
  print STDERR "    creating $filename\n";
  filter_nesc( "ConfigM.config.nc", $filename, \%subs );
}


sub create_config_configuration {
  my ($dir, $exts, $wiring) = @_;
  $dir .= "/" unless $dir =~ m/\/$/;

  my %subs = ( provides => "", wiring => "", components => "" );
  my %components = ();

  for my $ee (sort keys %{$exts}) {
    my $name = $exts->{$ee}->{name};
    my $iface = "Config_${name}";
    $subs{provides} .= "    interface ${iface};\n";
    $subs{wiring} .= "  ${iface} = ConfigM.${iface};\n";
  }

  $subs{wiring} .= "\n";

  for my $wire ( sort { $a->{interface} cmp $b->{interface}
                        || $a->{module} cmp $b->{module}
		      } @{$wiring} ) {
    $subs{wiring} .= "  $wire->{module} -> ConfigM.$wire->{interface};\n";
    $components{$wire->{module}} = 1;
  }

  $subs{components} .= "  components "
                     . join( "\n          , ", sort keys %components ) 
		     . "\n           ;\n" if %components;

  my $filename = "${dir}ConfigC.nc";
  print STDERR "    creating $filename\n";
  filter_nesc( "ConfigC.config.nc", $filename, \%subs );
}


