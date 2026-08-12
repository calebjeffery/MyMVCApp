use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Test::More;
use Test::MockModule;

BEGIN {
    $ENV{MULTIAPP_SKIP_MARIADB} = 1;
}

my $mock_user = Test::MockModule->new('MultiApp::Model::UserModel');
$mock_user->mock(
    authenticate_user => sub {
        my ( $class, $username, $password ) = @_;
        return { name => 'Test User' }
          if $username eq 'testuser' && $password eq 'testpass';
        return undef;
    }
);

my $mock_task = Test::MockModule->new('MultiApp::Model::TaskModel');
$mock_task->mock(
    list_tasks => sub {
        return [
            { id => 1, title => 'Sample', completed => 0, source => 'sqlite' },
        ];
    }
);

use MultiApp::Util::Bootstrap;
use MultiApp::Controller::HomeController;

sub run_request {
    my (%params) = @_;
    my $query = join '&', map { "$_=" . ( defined $params{$_} ? $params{$_} : '' ) } sort keys %params;

    local %ENV = (
        %ENV,
        GATEWAY_INTERFACE => 'CGI/1.1',
        REQUEST_METHOD    => 'GET',
        QUERY_STRING      => $query,
    );
    delete $ENV{HTTP_COOKIE};

    local *STDIN;
    open STDIN, '<', \'';
    require CGI;
    CGI->_reset_globals();

    my $output;
    {
        local *STDOUT;
        open STDOUT, '>', \$output;
        MultiApp::Controller::HomeController->new()->handle_request();
    }

    return $output;
}

like(
    run_request( action => 'login', username => 'testuser', password => 'testpass' ),
    qr/Location: index\.cgi\?action=tasks_list/,
    'login redirects to task dashboard'
);

like( run_request(), qr/Login/, 'unauthenticated users see login' );

done_testing();
