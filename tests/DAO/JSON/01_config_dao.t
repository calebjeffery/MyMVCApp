# Load perl main modules
use strict;
use warnings;
use Test::More;
use JSON::MaybeXS;
use File::Spec;

# Load modules from lib directory
use lib 'lib';
use MyApp::DAO::JSON::ConfigDAO;

# Directory for the configuration file
my $config_dir = 'P:/Projects/Learning/perlOO/MyMVCApp/tests/data/configuration';
my $config_file = File::Spec->catfile($config_dir, 'config.json');

# Cleanup from previous test runs
unlink $config_file if -e $config_file;

# Initialize ConfigDAO
my $config_dao = MyApp::DAO::JSON::ConfigDAO->new($config_dir);

# Test case: Check if the file exists after initialization
subtest 'Setup Config Data' => sub {
    plan tests => 1;
    ok(-e $config_file, "Config file '$config_file' exists after initialization");
};

# Test case: Reading initial configuration data
subtest 'Reading Initial Config Data' => sub {
    plan tests => 1;
    my $config = $config_dao->get_config();
    is_deeply($config, {}, 'Configuration data should be an empty hash initially');
};

# Test case: Writing and reading configuration data
subtest 'Writing and Reading Config Data' => sub {
    plan tests => 3;

    my $config_write = <<'EOF';
{
  "data_dirs" : {
    "tasks" : "P:/Projects/Learning/perlOO/MyMVCApp/data/tasks"
  },
  "settings" : {
    "key1" : "value1",
    "key2" : "value2"
  }
}
EOF

    # Write the configuration
    $config_dao->set_config($config_write);

    # Read the configuration back
    my $config_read = $config_dao->get_config();

    # Compare string representations ignoring whitespace
    my $actual_json = $config_dao->to_String();
    my $expected_json = $config_write;
    
    is($actual_json, $expected_json, 'Configuration data read matches configuration data written');

# Test case for set_value and get_value
    subtest 'Setting and Getting Values' => sub {
        plan tests => 2;

        # Test setting a new value
        my $new_value = '/new/path/to/tasks';
        $config_dao->set_value('data_dirs.tasks', $new_value);
        is($config_dao->get_value('data_dirs.tasks'), $new_value, 'Setting and getting a new value');

        # Test updating an existing value
        my $updated_value = 'value_updated';
        $config_dao->set_value('settings.key1', $updated_value);
        is($config_dao->get_value('settings.key1'), $updated_value, 'Updating and getting an existing value');
    };

    # Save the configuration
    $config_dao->save();

    # Check if the file contains the expected text
    open my $fh, '<', $config_file or die "Cannot open file $config_file: $!";
    local $/;  # Enable 'slurp' mode
    my $file_content = <$fh>;
    close $fh;

    # Ensure the file content matches the expected configuration
    my $expected_file_content = '{"data_dirs":{"tasks":"/new/path/to/tasks"},"settings":{"key1":"value_updated","key2":"value2"}}';
    chomp $file_content;
    chomp $expected_file_content;
    is($file_content, $expected_file_content, 'Config file contains the expected text');
};

done_testing();
