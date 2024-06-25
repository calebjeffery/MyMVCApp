package MyApp::Controller::LoginController;

use strict;
use warnings;
use CGI;
use CGI::Session;
use lib "lib";
use MyApp::Model::UserModel;
use MyApp::View::LoginView;
use MyApp::Util::SessionManager;
use Log::Log4perl;
use MyApp::Util::Files;
# Initialize Log4perl from configuration file
Log::Log4perl->init(MyApp::Util::Files::get_relative_path('data/configuration/log4perl.conf'));
my $logger = Log::Log4perl->get_logger(__PACKAGE__);


sub handle_request {
    my $cgi = CGI->new;
    my $session = CGI::Session->new(undef, $cgi, { Directory => '/tmp' });

    if ($cgi->request_method eq 'POST') {
        $logger->debug("Running Login Authentication");
        my $username = $cgi->param('username') || '';
        my $password = $cgi->param('password') || '';
        
        my $user = MyApp::Model::UserModel->authenticate_user($username, $password);
        
        $logger->debug("Authentication Checked");

        if ($user) {
             # Successful login
            my $session_manager = MyApp::Util::SessionManager->new();
            my $session = $session_manager->create_session($username);

            # Redirect to main page after login
            print $cgi->redirect('index.cgi');
            return;  # Ensure script exits after redirect
        } else {
            # Failed login
            print $cgi->header('text/html');
            print "<html><body>";
            print "<h2>Login failed. Please try again.</h2>";
            print MyApp::View::LoginView::render_login_form();
            print "</body></html>";
        }
    } else {
        # Display login form
        print $cgi->header('text/html');
        print "<html><body>";
        print MyApp::View::LoginView::render_login_form();
        print "</body></html>";
    }
    $session->flush();  # Save session data
}

1;
