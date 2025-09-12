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

sub load_llm_strings {
    my $fname = shift;
    my $fh = IO::File->new($fname, 'r');
    
    my @strings;

    for my $json ($fh->getlines()) {
        my $trans = decode_json($json);
        push @strings, $trans;
    };

    $fh->close();

    return @strings;
}

sub save_strings {
    my ($fname, $catalog) = @_;
    my $fh = IO::File->new($fname, 'w');

    my $json = encode_json($catalog);

    print $fh $json;

    $fh->close();
}

my $fname_catalog = shift @ARGV;
my $fname_llmstrings = shift @ARGV;

die "usage: $0 [Localizable.xcstrings] [llm-strings.json]" unless (defined $fname_catalog && defined $fname_llmstrings);

my $catalog = load_strings($fname_catalog);
my @llm_strings = load_llm_strings($fname_llmstrings);

my $strings = $catalog->{'strings'};

# iterate keys
for my $key (keys %$strings) {
    my $entry = $strings->{$key};
    my $llm_entry = (grep { $_->{'key'} eq $key } @llm_strings)[0];
    
    next if !exists $entry->{'localizations'};
    next if !defined $llm_entry;
    
    my $en_string = $llm_entry->{'en'} // '';
    
    unless ($en_string) {
        warn "no 'en' string for key '$key'";
        next;
    }
    
    # printf("filling key '%s' with text '%s'\n", $key, $en_string);
    
    $entry->{'localizations'}->{'en'} = {
        'stringUnit' => {
            'value' => $en_string,
            'state' => 'translated'
        }
    };
}

save_strings($fname_catalog, $catalog);
