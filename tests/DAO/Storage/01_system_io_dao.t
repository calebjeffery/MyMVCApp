# Load perl main modules
use strict;
use warnings;
use FindBin;
use Test::More;
use File::Spec;

use lib "$FindBin::Bin/../../../lib";
use MyApp::Util::Bootstrap;
use MyApp::DAO::Storage::SystemIODAO;

my $test_root = File::Spec->catdir( $FindBin::Bin, '../../data/test/storage' );
require File::Path;
File::Path::remove_tree($test_root) if -d $test_root;
File::Path::make_path($test_root);

my $dao = MyApp::DAO::Storage::SystemIODAO->new({ root_dir => $test_root });

subtest 'SystemIODAO store and fetch' => sub {
    plan tests => 3;

    my $pointer = '2026/07/sample.txt';
    my $content = 'hello storage';

    $dao->store($pointer, $content);
    ok( $dao->exists($pointer), 'file exists after store' );

    is( $dao->fetch($pointer), $content, 'fetched content matches stored content' );

    ok( $dao->delete($pointer), 'file deleted' );
};

done_testing();
