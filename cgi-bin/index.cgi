#!C:/MyApps/Perl/Strawberry/perl/bin/perl.exe
use strict;
use warnings;
use lib '../lib';
use MyApp::Controller::HomeController;
my $cgi = CGI->new;
my $controller = MyApp::Controller::HomeController->new();

# Determine the action based on CGI parameters
my $action = $cgi->param('action') || 'default';

if ($action eq 'login') {
    $controller->login_request($cgi);  # Process login request
} else {
    $controller->handle_request();  # Handle regular home page request
}