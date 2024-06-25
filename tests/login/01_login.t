#!/usr/bin/perl

use strict;
use warnings;
use FindBin;
use lib "lib";  # Add the lib directory to @INC

use Test::More tests => 2;
use Test::MockModule;
use MyApp::Controller::LoginController;
use MyApp::Model::UserModel;
use MyApp::Util::Files;
use CGI;

# Determine the path to the log4perl.conf file relative to the application's root directory
my $log_conf_path = MyApp::Util::Files::get_relative_path('data/configuration/log4perl.conf');
Log::Log4perl->init($log_conf_path);

# Mock UserModel
my $mock_user_model = Test::MockModule->new('MyApp::Model::UserModel');
$mock_user_model->mock('authenticate_user', sub {
    my ($class, $username, $password) = @_;
    return $username eq 'testuser' && $password eq 'testpass';
});

# Create CGI object with parameters for login
my $cgi = CGI->new;
$cgi->param('username', 'testuser');
$cgi->param('password', 'testpass');

# Capture output
my $output;
{
    local *STDOUT;
    open STDOUT, '>', \$output;
    MyApp::Controller::LoginController::handle_request();
}

# Tests
like($output, qr/Location: index\.cgi/, 'Redirects to index.cgi on successful login');

$cgi->param('username', 'wronguser');
$cgi->param('password', 'wrongpass');
{
    local *STDOUT;
    open STDOUT, '>', \$output;
    MyApp::Controller::LoginController::handle_request();
}

like($output, qr/Login failed/, 'Displays login failed message on unsuccessful login');

done_testing();
