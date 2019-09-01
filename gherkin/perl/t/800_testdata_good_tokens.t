#!perl

use strict;
use warnings;

use File::Find::Rule;
use File::Spec;
use Test2::V0;
use Test2::Tools::Spec;

use Gherkin::Parser;
use Gherkin::TokenFormatterBuilder;


my @feature_files =
    File::Find::Rule->new
    ->name('*.feature')
    ->in(File::Spec->catdir(qw(testdata good)));


describe tokenization => sub {
    my $feature;
    my @tokens;

    for my $file (@feature_files) {
        case feature => sub {
            $feature = $file;
            open my $fh, '<:utf8', "$feature.tokens"
                or die "Can't open $feature.tokens: $!";
            @tokens = <$fh>;
            close $fh
                or warn "Can't close $feature.tokens: $!";

            chomp for @tokens;
        };
    }

    tests feature_tokens => sub {
        my $parser =
            Gherkin::Parser->new( Gherkin::TokenFormatterBuilder->new() );
        # testdata/good/escaped_pipes.feature has an embedded newline in
        #  one of its tokens, meaning that the rest of the line is wrapped
        #  to its own line in the input tokens read from the tokens file
        # here we split the parsed tokens on embedded newlines to force
        #  the parsed content to be aligned with the content sourced from
        #  token files
        is([ map { split /\n/ }
             @{$parser->parse($feature)} ], \@tokens,
           "Parsed tokens match for $feature");

        done_testing;
    };
};


done_testing;
