use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../../lib";
use Test::More;
use File::Spec;
use MultiApp::DAO::JSON::ConfigDAO;
use MultiApp::DAO::Factory;

my $config_dir = File::Spec->catdir( $FindBin::Bin, '../../../data/configuration' );
my $config_dao = MultiApp::DAO::JSON::ConfigDAO->new($config_dir);

MultiApp::DAO::Factory::reset_instance();
my $factory = MultiApp::DAO::Factory->new($config_dao);

subtest 'sqlite DAO' => sub {
    plan tests => 1;
    my $dao = $factory->get_task_dao('sqlite');
    isa_ok( $dao, 'MultiApp::DAO::SQLite::TaskDAO' );
};

subtest 'api DAO' => sub {
    plan tests => 1;
    my $dao = $factory->get_task_dao('api');
    isa_ok( $dao, 'MultiApp::DAO::API::TaskDAO' );
};

subtest 'aggregate DAO' => sub {
    plan tests => 1;
    my $dao = $factory->get_task_dao('aggregate');
    isa_ok( $dao, 'MultiApp::DAO::Aggregate::TaskDAO' );
};

subtest 'config values' => sub {
    plan tests => 2;
    is( $config_dao->get_value('data_source'), 'sqlite', 'default data_source' );
    is(
        $config_dao->get_value('api.base_url'),
        'https://jsonplaceholder.typicode.com',
        'api base_url'
    );
};

done_testing();
