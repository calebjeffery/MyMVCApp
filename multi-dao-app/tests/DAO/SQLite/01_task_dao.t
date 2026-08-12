use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../../lib";
use Test::More;
use MultiApp::DAO::SQLite::TaskDAO;

my $dao = MultiApp::DAO::SQLite::TaskDAO->new( skip_schema => 0, file => ':memory:' );

subtest 'Create and find task' => sub {
    my $task = $dao->create( { title => 'Test task', completed => 0 } );
    ok( $task, 'create returns task' );
    is( $task->{title}, 'Test task', 'title set' );
    is( $task->{source}, 'sqlite', 'source tagged' );

    my $found = $dao->find_by_id( $task->{id} );
    is( $found->{title}, 'Test task', 'find_by_id works' );
};

subtest 'find_all returns tasks' => sub {
    $dao->create( { title => 'Another task' } );
    my $tasks = $dao->find_all();
    ok( @$tasks >= 2, 'find_all returns multiple tasks' );
};

subtest 'update task' => sub {
    my $task = $dao->create( { title => 'Toggle me' } );
    my $updated = $dao->update( $task->{id}, { title => 'Toggled', completed => 1 } );
    is( $updated->{completed}, 1, 'completed updated' );
    is( $updated->{title}, 'Toggled', 'title updated' );
};

subtest 'delete task' => sub {
    my $task = $dao->create( { title => 'Delete me' } );
    ok( $dao->delete( $task->{id} ), 'delete succeeds' );
    ok( !$dao->find_by_id( $task->{id} ), 'task removed' );
};

done_testing();
