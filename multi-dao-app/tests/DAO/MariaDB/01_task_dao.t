use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../../lib";
use Test::More;

BEGIN {
    if ( !$ENV{MULTIAPP_MARIADB_DSN} ) {
        plan skip_all => 'Set MULTIAPP_MARIADB_DSN to run MariaDB integration tests';
    }
}

use MultiApp::DAO::MariaDB::TaskDAO;

my $dao = MultiApp::DAO::MariaDB::TaskDAO->new(
    dsn      => $ENV{MULTIAPP_MARIADB_DSN},
    user     => $ENV{MULTIAPP_MARIADB_USER} // 'multiapp',
    password => $ENV{MULTIAPP_MARIADB_PASSWORD} // 'changeme',
);

my $task = $dao->create( { title => 'MariaDB task', completed => 0 } );
ok($task);
is( $task->{source}, 'mariadb' );

ok( $dao->delete( $task->{id} ) );

done_testing();
