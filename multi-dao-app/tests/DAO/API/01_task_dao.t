use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../../lib";
use Test::More;
use Test::MockModule;
use JSON::MaybeXS qw(encode_json decode_json);
use MultiApp::DAO::API::TaskDAO;

my $mock_http = Test::MockModule->new('HTTP::Tiny');

$mock_http->mock(
    request => sub {
        my ( $undef, $method, $url, $options ) = @_;

        if ( $method eq 'GET' && $url =~ m{/todos\z} ) {
            return {
                success => 1,
                status  => 200,
                content => encode_json(
                    [
                        { id => 1, userId => 1, title => 'API task', completed => 0 },
                    ]
                ),
            };
        }

        if ( $method eq 'GET' && $url =~ m{/todos/1\z} ) {
            return {
                success => 1,
                status  => 200,
                content => encode_json(
                    { id => 1, userId => 1, title => 'API task', completed => 0 }
                ),
            };
        }

        if ( $method eq 'POST' && $url =~ m{/todos\z} ) {
            my $body = decode_json( $options->{content} );
            return {
                success => 1,
                status  => 201,
                content => encode_json( { id => 201, userId => 1, %$body } ),
            };
        }

        if ( $method eq 'PUT' && $url =~ m{/todos/1\z} ) {
            my $body = decode_json( $options->{content} );
            return {
                success => 1,
                status  => 200,
                content => encode_json( { id => 1, userId => 1, %$body } ),
            };
        }

        if ( $method eq 'DELETE' && $url =~ m{/todos/1\z} ) {
            return { success => 1, status => 200, content => '{}' };
        }

        return { success => 0, status => 404, reason => 'Not Found' };
    }
);

my $dao = MultiApp::DAO::API::TaskDAO->new(
    base_url => 'https://jsonplaceholder.typicode.com',
    resource => 'todos',
);

subtest 'find_all maps API todos' => sub {
    my $tasks = $dao->find_all();
    is( scalar @$tasks, 1, 'one task returned' );
    is( $tasks->[0]{title}, 'API task', 'title mapped' );
    is( $tasks->[0]{source}, 'api', 'source tagged' );
};

subtest 'find_by_id' => sub {
    my $task = $dao->find_by_id(1);
    ok($task);
    is( $task->{id}, 1 );
};

subtest 'create update delete' => sub {
    my $created = $dao->create( { title => 'New', completed => 0 } );
    ok($created);
    is( $created->{id}, 201 );

    my $updated = $dao->update( 1, { title => 'Updated', completed => 1 } );
    is( $updated->{completed}, 1 );

    ok( $dao->delete(1) );
};

done_testing();
