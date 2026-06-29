#!/usr/bin/env perl
use strict;
use warnings;
use lib '../lib';
use MyApp::Util::Bootstrap;
use MyApp::Controller::LoginController;

MyApp::Controller::LoginController->handle_request();
