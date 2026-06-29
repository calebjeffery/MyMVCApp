#!/usr/bin/env perl
use strict;
use warnings;
use lib '../lib';
use MultiApp::Util::Bootstrap;
use MultiApp::Controller::HomeController;

my $controller = MultiApp::Controller::HomeController->new();
$controller->handle_request();
