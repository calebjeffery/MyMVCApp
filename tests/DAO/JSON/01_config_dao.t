# Load perl main modules
use strict;
use warnings;
use FindBin;
use Test::More;
use JSON::MaybeXS;
use File::Spec;

use lib "$FindBin::Bin/../../../lib";
use MyApp::Util::Bootstrap;
use MyApp::DAO::JSON::ConfigDAO;

my $config_dir  = File::Spec->catdir( $FindBin::Bin, '../../data/configuration' );
my $config_file = File::Spec->catfile( $config_dir, 'config.json' );

unlink $config_file if -e $config_file;

my $config_dao = MyApp::DAO::JSON::ConfigDAO->new($config_dir);

subtest 'Setup Config Data' => sub {
    plan tests => 1;
    ok( -e $config_file, "Config file '$config_file' exists after initialization" );
};

subtest 'Reading Initial Config Data' => sub {
    plan tests => 1;
    my $config = $config_dao->get_config();
    is_deeply( $config, {}, 'Configuration data should be an empty hash initially' );
};

subtest 'Writing and Reading Config Data' => sub {
    plan tests => 3;

    my $config_write = <<'EOF';
{
  "data_dirs" : {
    "tasks" : "data/tasks"
  },
  "settings" : {
    "key1" : "value1",
    "key2" : "value2"
  }
}
EOF

    $config_dao->set_config($config_write);
    is_deeply(
        $config_dao->get_config(),
        decode_json($config_write),
        'Configuration data read matches configuration data written'
    );

    subtest 'Setting and Getting Values' => sub {
        plan tests => 2;

        my $new_value = '/new/path/to/tasks';
        $config_dao->set_value( 'data_dirs.tasks', $new_value );
        is( $config_dao->get_value('data_dirs.tasks'), $new_value, 'Setting and getting a new value' );

        my $updated_value = 'value_updated';
        $config_dao->set_value( 'settings.key1', $updated_value );
        is( $config_dao->get_value('settings.key1'), $updated_value, 'Updating and getting an existing value' );
    };

    $config_dao->save();

    open my $fh, '<', $config_file or die "Cannot open file $config_file: $!";
    local $/;
    my $file_content = <$fh>;
    close $fh;

    my $expected_file_content =
      '{"data_dirs":{"tasks":"/new/path/to/tasks"},"settings":{"key1":"value_updated","key2":"value2"}}';
    chomp $file_content;
    chomp $expected_file_content;
    is( $file_content, $expected_file_content, 'Config file contains the expected text' );
};

done_testing();
