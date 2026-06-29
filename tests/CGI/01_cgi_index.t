#!/usr/bin/perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Test::More;
use Test::MockModule;
use CGI;

my $mock_user_model = Test::MockModule->new('MyApp::Model::UserModel');
$mock_user_model->mock(
    'authenticate_user',
    sub {
        my ( $class, $username, $password ) = @_;
        return { name => 'Test User' }
          if defined $username
          && defined $password
          && $username eq 'testuser'
          && $password eq 'testpass';
        return undef;
    }
);

use MyApp::Util::Bootstrap;
use MyApp::Controller::HomeController;

sub run_index_request {
    my (%params) = @_;

    my $query = join(
        '&',
        map { "$_=" . ( defined $params{$_} ? $params{$_} : '' ) } sort keys %params
    );

    local %ENV = (
        %ENV,
        GATEWAY_INTERFACE => 'CGI/1.1',
        REQUEST_METHOD    => 'GET',
        QUERY_STRING      => $query,
    );
    delete $ENV{HTTP_COOKIE};
    delete $ENV{CONTENT_LENGTH};
    delete $ENV{CONTENT_TYPE};

    local *STDIN;
    open STDIN, '<', \'';
    CGI->_reset_globals();

    my $output;
    {
        local *STDOUT;
        open STDOUT, '>', \$output;
        MyApp::Controller::HomeController->new()->handle_request();
    }

    return $output;
}

like(
    run_index_request( action => 'login', username => 'testuser', password => 'testpass' ),
    qr/Location: index\.cgi/,
    'index.cgi login redirects on success'
);

like(
    run_index_request(),
    qr/Login/,
    'index.cgi shows login form for unauthenticated users'
);

done_testing();
