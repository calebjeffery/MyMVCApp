# Load perl main modules
use strict;
use warnings;
use FindBin;
use Test::More;
use JSON::MaybeXS;
use File::Spec;

use lib "$FindBin::Bin/../../../lib";
use MyApp::Util::Bootstrap;
use MyApp::DAO::JSON::JsonFileDAO;

my $test_dir  = File::Spec->catdir( $FindBin::Bin, '../../data/test' );
my $json_file = File::Spec->catfile( $test_dir, 'test_file.json' );

require File::Path;
File::Path::make_path($test_dir) unless -d $test_dir;
unlink $json_file if -e $json_file;

my $json_file_dao = MyApp::DAO::JSON::JsonFileDAO->new($test_dir);

subtest 'Reading and writing JSON file' => sub {
    plan tests => 2;

    my $test_data = { key1 => 'value1', key2 => 'value2' };
    my $file_name = 'test_file.json';

    $json_file_dao->write_json( $file_name, $test_data );
    my $read_data = $json_file_dao->read_json($file_name);

    is_deeply( $read_data, $test_data, 'Data read matches data written' );

    open my $fh, '<', $json_file or die "Cannot open file $json_file: $!";
    local $/;
    my $file_content = <$fh>;
    close $fh;

    my $decoded_written_data = JSON::MaybeXS->new(utf8 => 1)->decode($file_content);
    my $canonical_written_json = JSON::MaybeXS->new( canonical => 1 )->encode($decoded_written_data);

    is( $file_content, $canonical_written_json, 'Written JSON is canonical' );
};

done_testing();
