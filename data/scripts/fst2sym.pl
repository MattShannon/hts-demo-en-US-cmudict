#!/usr/bin/perl
# ----------------------------------------------------------------- #
#           The HMM-Based Speech Synthesis System (HTS)             #
#           developed by HTS Working Group                          #
#           http://hts.sp.nitech.ac.jp/                             #
# ----------------------------------------------------------------- #
#                                                                   #
#  Copyright (c) 2008-2010  Nagoya Institute of Technology          #
#                           Department of Computer Science          #
#                                                                   #
# All rights reserved.                                              #
#                                                                   #
# Redistribution and use in source and binary forms, with or        #
# without modification, are permitted provided that the following   #
# conditions are met:                                               #
#                                                                   #
# - Redistributions of source code must retain the above copyright  #
#   notice, this list of conditions and the following disclaimer.   #
# - Redistributions in binary form must reproduce the above         #
#   copyright notice, this list of conditions and the following     #
#   disclaimer in the documentation and/or other materials provided #
#   with the distribution.                                          #
# - Neither the name of the HTS working group nor the names of its  #
#   contributors may be used to endorse or promote products derived #
#   from this software without specific prior written permission.   #
#                                                                   #
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND            #
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,       #
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF          #
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE          #
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS #
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,          #
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED   #
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,     #
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON #
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,   #
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY    #
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE           #
# POSSIBILITY OF SUCH DAMAGE.                                       #
# ----------------------------------------------------------------- #

if ( $#ARGV != 2 ) {
   print "perl fst2sym.pl infile1 infile2 outfile\n";
   exit(0);
}

$infile1 = $ARGV[0];
$infile2 = $ARGV[1];
$outfile = $ARGV[2];

@sym = ("<eps>");

open( I, "$infile1" );
while ( $line = <I> ) {
   @list = split( / /, $line );
   if ( length( $list[4] ) > 0 ) {
      push( @sym, $list[2] );
      push( @sym, $list[3] );
   }
}
close(I);

open( I, "$infile2" );
while ( $line = <I> ) {
   @list = split( / /, $line );
   if ( length( $list[4] ) > 0 ) {
      push( @sym, $list[2] );
      push( @sym, $list[3] );
   }
}
close(I);

open( O, "> $outfile" );
for ( $i = 0, $j = 0 ; $i < @sym ; $i++ ) {
   unless ( $seen{ $sym[$i] } ) {
      $seen{ $sym[$i] } = 1;
      print O "$sym[$i] $j\n";
      $j++;
   }
}
close(O);
