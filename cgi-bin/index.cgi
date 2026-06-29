#!/usr/bin/env perl
use strict;
use warnings;
use lib '../lib';
use MyApp::Util::Bootstrap;
use CGI;
use MyApp::Controller::HomeController;

my $controller = MyApp::Controller::HomeController->new();
$controller->handle_request();
