#!/usr/bin/env perl
use warnings;
use strict;
use JSON;
use Encode::Guess;

if ($#ARGV < 0) {
    print "Usage: convert-reg-json.pl [filename]\n";
    exit 0;
}

my ($sourceFile, $k, $v);
my %parameters;
my $keyName = "HASP Key";

$sourceFile = shift;
#print "$sourceFile\n";
#exit 0;
$sourceFile =~ s/(.*)\.reg$/$1/;

open WIN, "<$sourceFile.reg";
my $firstLine = <WIN>;
my $utf8;
close WIN;
open UNX, ">$sourceFile.tmp";
my $enc = guess_encoding($firstLine, qw/UTF-16LE/);
if (ref($enc) eq "Encode::XS") {
    open WIN, "<$sourceFile.reg";
    while (<WIN>) {
        $enc = guess_encoding($_, qw/Windows-1251/);
        if (ref($enc)) {
            $utf8 = $enc->decode($_);
        } else {
            $utf8 = $_;
        }
        print UNX trimStr($utf8);
    }
} elsif ($enc->{'Name'} =~ m/UTF-16/) {
    open WIN, "<:raw:encoding(UTF-16LE):crlf", "$sourceFile.reg";
    while (<WIN>) {
        print UNX trimStr($_);
    }
}
close WIN;
close UNX;

open SRC,"<$sourceFile.tmp";
while (<SRC>) {
    if ($_ =~ m/.*HKEY_LOCAL_MACHINE.*\\([a-fA-F0-9]{6,})]$/) {
        $parameters{$keyName}{'Password'} = $1;
    }
    if ($_ =~ m/^\"(\w+)\"=(.*)/) {
        $parameters{$keyName}{$1} = $2;
    }
}
close SRC;

unlink("$sourceFile.tmp");

while ( ($k,$v) = each %{$parameters{$keyName}} ) {
    if ($v =~ m/^\"(.*)\"$/) {
        $parameters{$keyName}{$k} = $1;
    }
    if ($v =~ m/^dword:(.*)/) {
        $parameters{$keyName}{$k} = $1;
    }
    if ($v =~ m/^hex:(.*)/) {
        $v = $1;
        $v =~ s/([a-fA-F0-9]{2},*)/0x$1/g;
        $parameters{$keyName}{$k} = $v;
    }
}

my $JSON = JSON->new->pretty;
my $output = $JSON->encode(\%parameters);
open JSF, ">$sourceFile.json";
print JSF $output;
close JSF;

sub trimStr {
    my $str = shift;
    $str =~ s/\r\n$/\n/;
    $str =~ s/\\\n//;
    $str =~ s/^\s+//;
    return $str;
}