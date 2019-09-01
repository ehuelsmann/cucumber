#!perl

use strict;
use warnings;

use File::Find::Rule;
use File::Spec;
use Test2::V0;

use Gherkin::Parser;

my @feature_files =
    File::Find::Rule->new
    ->name('*.feature')
    ->in(File::Spec->catdir(qw(testdata good)));



for my $feature (@feature_files) {
    subtest $feature, sub {
        ok(
            lives {
                my $parser = Gherkin::Parser->new;
                $parser->parse( $feature );
            }, 'Parse feature without errors', $@ ? $@->message : '');
        done_testing;
    };
}


done_testing;
