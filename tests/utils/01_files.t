#!/usr/bin/perl

use strict;
use warnings;
use FindBin;
use File::Spec;
use Cwd qw(abs_path);
use lib "$FindBin::Bin/../../lib";
use Test::More;
use MyApp::Util::Files;

subtest 'get_relative_path' => sub {
    my $test_file     = 'cpanfile';
    my $expected_path = abs_path( File::Spec->catfile( $FindBin::Bin, '../../', $test_file ) );
    my $resolved_path = MyApp::Util::Files::get_relative_path($test_file);

    is( $resolved_path, $expected_path, 'Resolved path matches expected project root file' );
};

done_testing();
