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
use MyApp::Controller::LoginController;

sub run_post_login {
    my ( $username, $password ) = @_;
    my $body = "username=$username&password=$password";

    local %ENV = (
        %ENV,
        GATEWAY_INTERFACE => 'CGI/1.1',
        REQUEST_METHOD    => 'POST',
        CONTENT_TYPE      => 'application/x-www-form-urlencoded',
        CONTENT_LENGTH    => length($body),
        QUERY_STRING      => '',
    );
    delete $ENV{HTTP_COOKIE};

    local *STDIN;
    open STDIN, '<', \$body;
    CGI->_reset_globals();

    my $output;
    {
        local *STDOUT;
        open STDOUT, '>', \$output;
        MyApp::Controller::LoginController::handle_request();
    }

    return $output;
}

like(
    run_post_login( 'testuser', 'testpass' ),
    qr/Location: index\.cgi/,
    'Redirects to index.cgi on successful login'
);

like(
    run_post_login( 'wronguser', 'wrongpass' ),
    qr/Login failed/,
    'Displays login failed message on unsuccessful login'
);

done_testing();
