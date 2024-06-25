package MyApp::Controller::HomeController;

use strict;
use warnings;
use CGI;
use MyApp::Model::UserModel;
use MyApp::View::LoginView;
use MyApp::View::HomeView;
use MyApp::Util::SessionManager;
use Log::Log4perl;
use MyApp::Util::Files;

# Initialize Log4perl from configuration file
Log::Log4perl->init(MyApp::Util::Files::get_relative_path('data/configuration/log4perl.conf'));
my $logger = Log::Log4perl->get_logger(__PACKAGE__);

sub new {
    my ($class) = @_;
    my $self = {};
    bless $self, $class;
    return $self;
}

sub handle_request {
    my ($self) = @_;
    $logger->debug("Handling request");

    my $cgi = CGI->new;

    my $action = $cgi->param('action') || '';
    $logger->debug("Action parameter: $action");

    if ($action eq 'logout') {
        $self->logout_request($cgi);
    } else {
        $self->process_request($cgi);
    }
}

sub process_request {
    my ($self, $cgi) = @_;
    $logger->debug("Processing request");

    # Check if user is logged in
    my $session = $self->get_session($cgi);
    if ($session) {
        my $username = $session->param('username');
        $logger->debug("Session username: " . (defined $username ? $username : 'undef'));

        if ($username) {
            # User is logged in, display home page
            $logger->info("User is logged in as $username");
            $self->show_home_page($cgi, $username);
        } else {
            # No username in session, treat as not logged in
            $logger->info("User is not logged in");
            if ($cgi->param('action') && $cgi->param('action') eq 'login') {
                $self->login_request($cgi);
            } else {
                $self->show_login_form($cgi);
            }
        }
    } else {
        # No session found, treat as not logged in
        $logger->info("No session found");
        if ($cgi->param('action') && $cgi->param('action') eq 'login') {
            $self->login_request($cgi);
        } else {
            $self->show_login_form($cgi);
        }
    }
}

sub login_request {
    my ($self, $cgi) = @_;
    my $username = $cgi->param('username');
    my $password = $cgi->param('password');
    $logger->debug("Login request with username: $username");

    my $user = MyApp::Model::UserModel->authenticate_user($username, $password);

    if ($user) {
        # Successful login
        $logger->info("Login successful for username: $username");
        my $session = MyApp::Util::SessionManager::create_session();
        $session->param('username', $username);
        $logger->debug("Session created for username: $username");

        print $cgi->redirect('index.cgi');  # Redirect to home page after successful login
    } else {
        # Failed login
        $logger->warn("Login failed for username: $username");
        $self->show_login_failed($cgi);
    }
}

sub logout_request {
    my ($self, $cgi) = @_;
    $logger->debug("Logout request");

    my $session = $self->get_session($cgi);

    if ($session) {
        $logger->info("Deleting session");
        $session->delete();
        $session->flush();
        print $cgi->redirect('index.cgi');  # Redirect to home page after logout
    } else {
        # No active session, redirect to login or home page as needed
        $logger->warn("No active session found for logout");
        print $cgi->redirect('index.cgi');  # Redirect to home page
    }
}

sub show_login_form {
    my ($self, $cgi) = @_;
    $logger->debug("Displaying login form");

    print $cgi->header('text/html');
    print MyApp::View::LoginView::render_login_form();
}

sub show_login_failed {
    my ($self, $cgi) = @_;
    $logger->debug("Displaying login failed message");

    print $cgi->header('text/html');
    print MyApp::View::LoginView::render_login_failed();
    print MyApp::View::LoginView::render_login_form();
}

sub show_home_page {
    my ($self, $cgi, $username) = @_;
    $logger->debug("Displaying home page for username: $username");

    print $cgi->header('text/html');
    print MyApp::View::HomeView::render_home_page($username);
}

sub get_session {
    my ($self, $cgi) = @_;
    $logger->debug("Getting session");

    return MyApp::Util::SessionManager::get_session($cgi);
}

1;
