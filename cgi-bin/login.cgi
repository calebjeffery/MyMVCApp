#!C:/MyApps/Perl/Strawberry/perl/bin/perl.exe
use strict;
use warnings;
use CGI;
use CGI::Session;
use lib '../lib';
use MyApp::Controller::LoginController;

# Initialize CGI object
my $cgi = CGI->new;


MyApp::Controller::LoginController->handle_request();
