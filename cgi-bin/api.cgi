#!/usr/bin/env perl
use strict;
use warnings;
use lib '../lib';
use MyApp::Util::Bootstrap;
use MyApp::Controller::FileController;

print "Access-Control-Allow-Origin: *\n";
print "Access-Control-Allow-Methods: GET, POST, DELETE, OPTIONS\n";
print "Access-Control-Allow-Headers: Content-Type\n";

my $controller = MyApp::Controller::FileController->new();
$controller->handle_request();
