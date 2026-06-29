package MultiApp::Controller::HomeController;

use strict;
use warnings;
use CGI;
use MultiApp::Model::UserModel;
use MultiApp::View::LoginView;
use MultiApp::Controller::TaskController;
use MultiApp::Util::SessionManager;
use Log::Log4perl;

my $logger = Log::Log4perl->get_logger(__PACKAGE__);

my @TASK_ACTIONS = qw(tasks_list task_create task_toggle task_delete set_source);

sub new {
    my ($class) = @_;
    return bless {}, $class;
}

sub handle_request {
    my ($self) = @_;
    $logger->debug('Handling request');

    my $cgi    = CGI->new;
    my $action = $cgi->param('action') || '';

    if ( $action eq 'logout' ) {
        $self->logout_request($cgi);
    }
    elsif ( $action eq 'login' ) {
        $self->login_request($cgi);
    }
    elsif ( grep { $_ eq $action } @TASK_ACTIONS ) {
        $self->_handle_task_request( $cgi, $action );
    }
    else {
        $self->process_request($cgi);
    }
}

sub process_request {
    my ( $self, $cgi ) = @_;

    my $session = $self->get_session($cgi);
    if ( MultiApp::Util::SessionManager::is_session_valid($session) ) {
        print $cgi->redirect('index.cgi?action=tasks_list');
    }
    else {
        $self->show_login_form($cgi);
    }
}

sub login_request {
    my ( $self, $cgi ) = @_;
    my $username = $cgi->param('username');
    my $password = $cgi->param('password');

    my $user = MultiApp::Model::UserModel->authenticate_user( $username, $password );

    if ($user) {
        my $session = MultiApp::Util::SessionManager::create_session( $cgi, $username );
        MultiApp::Util::SessionManager::set_data_source( $session, 'sqlite' );
        print $cgi->redirect('index.cgi?action=tasks_list');
    }
    else {
        $self->show_login_failed($cgi);
    }
}

sub logout_request {
    my ( $self, $cgi ) = @_;
    my $session = $self->get_session($cgi);

    if ( $session && $session->param('username') ) {
        $session->delete();
        $session->flush();
    }

    print $cgi->redirect('index.cgi');
}

sub _handle_task_request {
    my ( $self, $cgi, $action ) = @_;
    my $session = $self->get_session($cgi);

    unless ( MultiApp::Util::SessionManager::is_session_valid($session) ) {
        $self->show_login_form($cgi);
        return;
    }

    MultiApp::Controller::TaskController->new->handle_request( $cgi, $session, $action );
}

sub show_login_form {
    my ( $self, $cgi ) = @_;
    print $cgi->header('text/html');
    print MultiApp::View::LoginView::render_login_form();
}

sub show_login_failed {
    my ( $self, $cgi ) = @_;
    print $cgi->header('text/html');
    print MultiApp::View::LoginView::render_login_failed();
    print MultiApp::View::LoginView::render_login_form();
}

sub get_session {
    my ( $self, $cgi ) = @_;
    return MultiApp::Util::SessionManager::get_session($cgi);
}

1;
