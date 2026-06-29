package MyApp::Controller::LoginController;

use strict;
use warnings;
use CGI;
use MyApp::Controller::HomeController;
use Log::Log4perl;

my $logger = Log::Log4perl->get_logger(__PACKAGE__);

# Legacy entry point: delegate all login handling to HomeController.
sub handle_request {
    my $cgi = CGI->new;
    my $controller = MyApp::Controller::HomeController->new;

    if ( $cgi->request_method eq 'POST' ) {
        $logger->debug('Delegating POST login to HomeController');
        $controller->login_request($cgi);
    }
    else {
        $logger->debug('Delegating login form display to HomeController');
        $controller->show_login_form($cgi);
    }
}

1;
