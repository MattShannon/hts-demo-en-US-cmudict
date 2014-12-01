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
   print "perl fst2lab.pl frameshift infile outfile\n";
   exit(0);
}

$fshift  = $ARGV[0];    # frame shift (s)
$infile  = $ARGV[1];
$outfile = $ARGV[2];

open( I, "$infile" )    || die "cannot open file : $infile";
open( O, "> $outfile" ) || die "cannot open file : $outfile";

$i_node = -1;           # initial node
$f_node = -1;           # final node
@t_list = ();           # transition list
@f_list = ();           # frame list
@s_list = ();           # state list

while ( $line = <I> ) {
   chomp($line);
   @list = split( /	/, $line );
   if ( length( $list[2] ) > 0 ) {
      if ( $i_node < 0 ) {
         $i_node = $list[0];
      }
      $t_list[ $list[0] ] = $list[1];
      $f_list[ $list[0] ] = $list[2];
      $s_list[ $list[0] ] = $list[3];
   }
   elsif ( $f_node < 0 ) {
      $f_node = $list[0];
   }
   else {
      die "unknown format : $list[0]\n";
   }
}

if ( @t_list <= 0 || @f_list <= 0 || @s_list <= 0 ) {
   die "no transition : $infile";
}

@fslist = ();    # frame list (sort)
@sslist = ();    # state list (sort)

for ( $i = $i_node ; $i != $f_node ; ) {
   if ( $f_list[$i] ne "," && length( $f_list[$i] ) > 0 ) {
      push( @fslist, $f_list[$i] );
   }
   if ( $s_list[$i] ne "," && length( $s_list[$i] ) > 0 ) {
      push( @sslist, $s_list[$i] );
   }
   $i = $t_list[$i];
}

for ( $i = 0, $j = 0 ; $i < @fslist ; $i++ ) {
   $tmp1 = substr( $sslist[$i], 0, rindex( $sslist[$i], "_m" ) );
   $tmp2 = substr( $sslist[$i], rindex( $sslist[$i],    "_m" ) + 2 );
   $tmp3 = substr( $sslist[$i], rindex( $sslist[$i],    "_s" ) + 2 );
   substr( $tmp2, index( $tmp2, "_" ) ) = "";
   if ( $i + 1 == @fslist ) {
      $s = $j * $fshift * 1e+07;
      $e = $i * $fshift * 1e+07;
      print O "$s $e $tmp1\n";
   }
   else {
      $tmp4 = substr( $sslist[ $i + 1 ], rindex( $sslist[ $i + 1 ], "_m" ) + 2 );
      substr( $tmp4, index( $tmp4, "_" ) ) = "";
      if ( $tmp2 != $tmp4 ) {
         $s = $j * $fshift * 1e+07;
         $e = $i * $fshift * 1e+07;
         print O "$s $e $tmp1\n";
         $j = $i;
      }
   }
}

close(O);
close(I);
