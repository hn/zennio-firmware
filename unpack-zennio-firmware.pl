#!/usr/bin/perl
#
# unpack-zennio-firmware.pl -- Unpack Zennio PAK firmware files
#
# (C) 2022 Hajo Noerenberg
#
# Usage: unpack-zennio-firmware.pl Z41_Pro-3.6.0/Z41_Pro_update.pak
#
# http://www.noerenberg.de/
# https://github.com/hn/zennio-firmware
#
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3.0 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/gpl-3.0.txt>.
#

use strict;

my $f = $ARGV[0];
open( IF, "<$f" ) || die( "Unable to open input file '$f': " . $! );
binmode(IF);

my $fpre = "Z";
my $buf;
my @toc;
my $dsecs = 0;

print "\nWarning: Alpha Status, various things are unknown and/or wrong!\n\n";

# 4 bytes signature, e.g. "Z41A"

read( IF, $buf, 4 ) == 4 || die;
my $pretty = $buf;
$pretty =~ s/[^[:print:]]/./g;
printf( "Signature: %s - %s\n\n", unpack( "H*", $buf ), $pretty );

# 16 * 62 = 992 bytes table of contents

for my $i ( 0 .. 15 ) {
    my $pbuf;
    read( IF, $buf, 62 ) == 62 || die;
    $pbuf = substr( $buf, 25 + 32 + 4, 1 );
    my $ena = $pbuf;
    $ena =~ s/[^[:print:]]/./g;
    printf( "ToC %2d En: %-64s - %s\n", $i, unpack( "H*", $pbuf ), $ena );
    next if ( $pbuf eq "\x00" );
    $pbuf = substr( $buf, 0, 25 );
    my $id = $pbuf;
    $id =~ s/[^[:print:]]/./g;
    $id =~ s/\.+$//;
    printf( "ToC %2d Id: %-64s - %s\n", $i, unpack( "H*", $pbuf ), $id );
    $pbuf = substr( $buf, 25, 32 );
    my $fn = $pbuf;
    $fn =~ s/[^[:print:]]/./g;
    $fn =~ s/\.+$//;
    printf( "ToC %2d Fn: %-64s - %s\n", $i, unpack( "H*", $pbuf ), $fn );
    $pbuf = substr( $buf, 25 + 32, 4 );
    my $off = unpack( "N", $pbuf );
    printf( "ToC %2d Of: %-64s - %d\n", $i, unpack( "H*", $pbuf ), $off );

    if ( $off > 0 ) {
        if ( $id eq "User" ) {
            $fpre = $fn;
        }
        if ( ( $id ne "Keys" ) && ( $id ne "Sigs" ) ) {
            $dsecs++;
        }
        $toc[$i]{id}    = $id;
        $toc[$i]{fn}    = $fn;
        $toc[$i]{start} = $off;
        $toc[$i]{end}   = -s $f;
        if ( $i > 0 ) {
            $toc[ $i - 1 ]{end} = $off;
        }
    }

    print "\n";
}

print "\nData (!Keys, !Sigs) sections: $dsecs\n\n";

# Process ToC, write data files

printf( "   %10s %22s %10s %10s %10s\n", "Id", "Filename", "Start", "End", "Length" );
for my $i ( 0 .. $#toc ) {
    my $len = $toc[$i]{end} - $toc[$i]{start};
    my $outfile =
      sprintf( "%s-section-%d-%09d-%09d-%s-%s.bin", $fpre, $i, $toc[$i]{start}, $len, $toc[$i]{id}, $toc[$i]{fn} );
    printf( "%2d %10s %22s %10d %10d %10d %s",
        $i, $toc[$i]{id}, $toc[$i]{fn}, $toc[$i]{start}, $toc[$i]{end}, $len, $outfile );

    seek( IF, $toc[$i]{start}, 0 );
    read( IF, $buf, $len ) == $len || die;
    open( OF, ">$outfile" ) || die( "Unable to open output file '$outfile': " . $! );
    binmode(OF);
    print OF $buf;
    close(OF);

    # $dsec * 256 byte keys

    if ( ( $toc[$i]{id} eq "Keys" ) && ( $len >= ( 256 * ( $dsecs + 1 ) ) ) ) {
        for my $k ( 0 .. $dsecs - 1 ) {
            print " K$k";
            my $keyfile = sprintf( "%s-keys-%d-%s.bin", $fpre, $k, $toc[$i]{fn} );
            open( OF, ">$keyfile" ) || die( "Unable to open output file '$keyfile': " . $! );
            binmode(OF);
            print OF substr( $buf, $k * 256, 256 );
            close(OF);
        }
    }

    # $dsec * 256 byte sigs

    if ( ( $toc[$i]{id} eq "Sigs" ) && ( $len >= ( 256 * ( $dsecs + 1 ) ) ) ) {
        for my $s ( 0 .. $dsecs - 1 ) {
            print " S$s";
            my $sigfile = sprintf( "%s-sigs-%d-%s.bin", $fpre, $s, $toc[$i]{fn} );
            open( OF, ">$sigfile" ) || die( "Unable to open output file '$sigfile': " . $! );
            binmode(OF);
            print OF substr( $buf, $s * 256, 256 );
            close(OF);
        }
    }

    print "\n";
}

