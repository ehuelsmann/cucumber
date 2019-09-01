#!perl

use strict;
use warnings;

use Path::Class qw/file/;
use Test2::V0;
use Test2::Tools::Spec;

use Gherkin::Parser;
use Gherkin::TokenScanner;

# Three different ways we can pass content to the parser, try each and check
# we get the same thing back each time.

my $file = file(qw/testdata good background.feature/);
my $content = $file->slurp;
my %results;

describe 'various parser inputs', sub {
    my ( $type, $input );

    case 'input', sub { # By filename
        $type = 'filename';
        $input = '' . $file;
    };
    case 'input', sub { # By content
        $type = 'stringref';
        $input = \$content;
    };
    case 'input', sub { # Object
        $type = 'scanner';
        $input = Gherkin::TokenScanner->new( '' . $file );
    };

    tests parse => sub {
        ok(
            lives {
                $results{$type} = Gherkin::Parser->new->parse( $input );
            },
            "Parsing via $type lived" );
    };
};

my $reference_type;
my $reference_copy;

# this checks the result of the first invocation with those of the second
# and third to be all the same. There's unfortunately no nice SPEC for that
for my $type (sort keys %results) {
    my $examine = delete $results{ $type };

    if ( $reference_copy ) {
        is( $examine, $reference_copy,
            "Result via $type matches result via $reference_type" );
    }

    $reference_type = $type;
    $reference_copy = $examine;
}

done_testing;

1;
