#!/usr/bin/perl
use 5.32.0;
use utf8;
use strict;
use warnings;

use IO::File;
use Encode qw/encode decode/;
use JSON qw/encode_json decode_json/;
use Data::Dumper;


sub load_strings {
    my $fname = shift;
    my $fh = IO::File->new($fname, 'r');

    my $json = join "", $fh->getlines();

    my $strings = decode_json($json);

    $fh->close();

    return $strings;
}

my $fname = shift @ARGV || die "usage: $0 [Localizable.xcstrings]";

my $catalog = load_strings($fname);

my $strings = $catalog->{'strings'};

# iterate keys
for my $key (keys %$strings) {
    my $entry = $strings->{$key};
    
    next if (!exists $entry->{'localizations'}) && (!exists $entry->{'comment'});
    
    my $comment = $entry->{'comment'};
    my $ko = $entry->{'localizations'}{'ko'}{'stringUnit'}{'value'} // '';
    my $en = exists $entry->{'localizations'}{'en'}{'stringUnit'}{'value'} // '';

    next if $ko eq '';
    
    say encode_json({ key => $key, ko => $ko, en => $en, comment => $comment });
}

