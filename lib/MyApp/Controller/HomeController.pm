package MyApp::Controller::HomeController;

use strict;
use warnings;
use CGI;
use MyApp::Model::UserModel;
use MyApp::Model::HomeModel;
use MyApp::View::LoginView;
use MyApp::View::HomeView;
use MyApp::Util::SessionManager;
use Log::Log4perl;

my $logger = Log::Log4perl->get_logger(__PACKAGE__);

sub new {
    my ($class) = @_;
    my $self = {};
    bless $self, $class;
    return $self;
}

sub handle_request {
    my ($self) = @_;
    $logger->debug('Handling request');

    my $cgi = CGI->new;
    my $action = $cgi->param('action') || '';
    $logger->debug("Action parameter: $action");

    if ($action eq 'logout') {
        $self->logout_request($cgi);
    } elsif ($action eq 'login') {
        $self->login_request($cgi);
    } else {
        $self->process_request($cgi);
    }
}

sub process_request {
    my ($self, $cgi) = @_;
    $logger->debug('Processing request');

    my $session = $self->get_session($cgi);
    if (MyApp::Util::SessionManager::is_session_valid($session)) {
        my $username = $session->param('username');
        $logger->info("User is logged in as $username");
        $self->show_home_page($cgi, $username);
    } else {
        $logger->info('User is not logged in');
        $self->show_login_form($cgi);
    }
}

sub login_request {
    my ($self, $cgi) = @_;
    my $username = $cgi->param('username');
    my $password = $cgi->param('password');
    $logger->debug("Login request with username: $username");

    my $user = MyApp::Model::UserModel->authenticate_user($username, $password);

    if ($user) {
        $logger->info("Login successful for username: $username");
        MyApp::Util::SessionManager::create_session($cgi, $username);
        print $cgi->redirect('index.cgi');
    } else {
        $logger->warn("Login failed for username: $username");
        $self->show_login_failed($cgi);
    }
}

sub logout_request {
    my ($self, $cgi) = @_;
    $logger->debug('Logout request');

    my $session = $self->get_session($cgi);

    if ($session && $session->param('username')) {
        $logger->info('Deleting session');
        $session->delete();
        $session->flush();
    } else {
        $logger->warn('No active session found for logout');
    }

    print $cgi->redirect('index.cgi');
}

sub show_login_form {
    my ($self, $cgi) = @_;
    $logger->debug('Displaying login form');

    print $cgi->header('text/html');
    print MyApp::View::LoginView::render_login_form();
}

sub show_login_failed {
    my ($self, $cgi) = @_;
    $logger->debug('Displaying login failed message');

    print $cgi->header('text/html');
    print MyApp::View::LoginView::render_login_failed();
    print MyApp::View::LoginView::render_login_form();
}

sub show_home_page {
    my ($self, $cgi, $username) = @_;
    $logger->debug("Displaying home page for username: $username");

    my $home_model = MyApp::Model::HomeModel->new;
    my $data = $home_model->get_data;

    print $cgi->header('text/html');
    print MyApp::View::HomeView::render_home_page($username, $data);
}

sub get_session {
    my ($self, $cgi) = @_;
    $logger->debug('Getting session');

    return MyApp::Util::SessionManager::get_session($cgi);
}

1;
