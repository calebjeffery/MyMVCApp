# Load perl main modules
use strict;
use warnings;
use Test::More;
use JSON::MaybeXS;
use File::Spec;

# Load modules from lib directory
use lib 'lib';
use MyApp::DAO::JSON::JsonFileDAO;
use Log::Log4perl;
Log::Log4perl->init('data/configuration/log4perl.conf');
# Get the logger instance
my $logger = Log::Log4perl->get_logger();

# Directory for the test JSON file
my $test_dir = 'P:/Projects/Learning/perlOO/MyMVCApp/tests/data/test';
my $json_file = File::Spec->catfile($test_dir, 'test_file.json');

# Cleanup from previous test runs
unlink $json_file if -e $json_file;

# Initialize JsonFileDAO
my $json_file_dao = MyApp::DAO::JSON::JsonFileDAO->new($test_dir);

# Subtest for reading and writing JSON file
subtest 'Reading and writing JSON file' => sub {
    plan tests => 2;  # Plan to run 2 tests within this subtest

    my $test_data = { key1 => 'value1', key2 => 'value2' };
    my $file_name = 'test_file.json';

    # Write test data to JSON file
    $json_file_dao->write_json($file_name, $test_data);

    # Read JSON file and verify contents
    my $read_data = $json_file_dao->read_json($file_name);
    
    is_deeply($read_data, $test_data, 'Data read matches data written');

    # Check if the written JSON is canonical
    my $file_content;
    {
        open my $fh, '<', $json_file or die "Cannot open file $json_file: $!";
        local $/;
        $file_content = <$fh>;
        close $fh;
    }

    my $decoded_written_data = JSON->new->utf8->decode($file_content);
    my $canonical_written_json = JSON->new->canonical(1)->encode($decoded_written_data);

    is($file_content, $canonical_written_json, 'Written JSON is canonical');
};

done_testing();  # End of test script, ensure all tests have completed
