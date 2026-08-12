use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../../lib";
use Test::More;
use Test::MockModule;
use JSON::MaybeXS qw(encode_json);
use MultiApp::DAO::SQLite::TaskDAO;
use MultiApp::DAO::API::TaskDAO;
use MultiApp::DAO::Aggregate::TaskDAO;

my $sqlite = MultiApp::DAO::SQLite::TaskDAO->new( file => ':memory:' );
$sqlite->create( { title => 'Local task' } );

my $mock_http = Test::MockModule->new('HTTP::Tiny');
$mock_http->mock(
    request => sub {
        return {
            success => 1,
            status  => 200,
            content => encode_json(
                [ { id => 1, userId => 1, title => 'Remote task', completed => 1 } ]
            ),
        };
    }
);

my $api = MultiApp::DAO::API::TaskDAO->new(
    base_url => 'https://jsonplaceholder.typicode.com',
    resource => 'todos',
);

my $aggregate = MultiApp::DAO::Aggregate::TaskDAO->new(
    daos => {
        sqlite => $sqlite,
        api    => $api,
    },
    write_source => 'sqlite',
);

subtest 'merges tasks from multiple sources' => sub {
    my $tasks = $aggregate->find_all();
    ok( @$tasks >= 2, 'aggregate returns tasks from sqlite and api' );
};

subtest 'create routes to write source' => sub {
    my $task = $aggregate->create( { title => 'Aggregate write' } );
    ok($task);
    is( $task->{source}, 'sqlite' );
};

done_testing();
