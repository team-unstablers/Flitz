#!/usr/bin/perl
use 5.32.0;
use utf8;
use strict;
use warnings;

use IO::File;
use JSON qw/encode_json decode_json/;
use Data::Dumper;

binmode STDOUT, ':utf8';

sub load_strings {
    my $fname = shift;
    my $fh = IO::File->new($fname, 'r');

    my $json = join "", $fh->getlines();

    my $strings = decode_json($json);

    $fh->close();

    return $strings;
}

sub save_strings {
    my ($fname, $catalog) = @_;
    my $fh = IO::File->new($fname, 'w');

    my $json = encode_json($catalog);

    print $fh $json;

    $fh->close();
}

my $fname = shift @ARGV || die "usage: $0 [Localizable.xcstrings]";

my $catalog = load_strings($fname);

my $strings = $catalog->{'strings'};

# iterate keys
for my $key (keys %$strings) {
    my $entry = $strings->{$key};
    
    next if exists $entry->{'localizations'};
    next if !exists $entry->{'comment'};
    
    my $comment = $entry->{'comment'};
    
    printf("filling key '%s' with comment '%s'\n", $key, $comment);
    
    $entry->{'localizations'} = {
        'ko' => {
            'stringUnit' => {
                'value' => $comment,
                'state' => 'translated'
            }
        }
    };
}

save_strings($fname, $catalog);
