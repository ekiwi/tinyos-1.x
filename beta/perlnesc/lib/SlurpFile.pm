#$Id: SlurpFile.pm,v 1.1 2004/07/15 18:25:40 cssharp Exp $

# "Copyright (c) 2000-2003 The Regents of the University of California.  
# All rights reserved.
#
# Permission to use, copy, modify, and distribute this software and its
# documentation for any purpose, without fee, and without written agreement
# is hereby granted, provided that the above copyright notice, the following
# two paragraphs and the author appear in all copies of this software.
# 
# IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
# DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
# OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY
# OF CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 
# THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
# ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
# PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS."

# @author Cory Sharp <cssharp@eecs.berkeley.edu>

package SlurpFile;

sub slurp_file {
  my ($file) = @_;
  return "" unless defined $file;
  my $fh;
  open $fh, "< $file" or die "ERROR, module file $file, $!, aborting.\n";
  my $text = do { local $/; <$fh> };
  close $fh;
  return $text;
}


sub dump_file {
  my ($file,$text) = @_;
  my $fh;
  open $fh, "> $file" or die "ERROR, writing file $file, $!, aborting.\n";
  print $fh $text;
  close $fh;
  1;
}

sub scrub_c_comments {
  my $text = shift;
  $text =~ s{/\*.*?\*/}{}gs;
  $text =~ s{//.*?\n}{}g;
  return $text;
}

1;


