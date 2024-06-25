# tests/util/files.t

use strict;
use warnings;
use Test::More;

use FindBin qw($Bin);
use File::Spec;
use lib 'lib';
use MyApp::Util::Files;

# Test 1: Test get_relative_path function
subtest 'get_relative_path' => sub {
    my $test_file = 'data/configuration/log4perl.conf';
    my $expected_path = File::Spec->catfile($Bin, '../../', $test_file);
    my $resolved_path = MyApp::Util::Files::get_relative_path($test_file);

    is($resolved_path, $expected_path, "Resolved path matches expected");
};

done_testing();
