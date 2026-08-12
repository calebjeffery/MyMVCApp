package MultiApp::Controller::TaskController;

use strict;
use warnings;
use MultiApp::Model::TaskModel;
use MultiApp::View::TaskView;
use MultiApp::Util::SessionManager;
use Log::Log4perl;

my $logger = Log::Log4perl->get_logger(__PACKAGE__);

sub new {
    my ($class) = @_;
    return bless {}, $class;
}

sub handle_request {
    my ( $self, $cgi, $session, $action ) = @_;

    my $data_source  = MultiApp::Util::SessionManager::get_data_source($session)
      // 'sqlite';
    my $write_source = $data_source eq 'aggregate' ? 'sqlite' : $data_source;

    my $model = MultiApp::Model::TaskModel->new(
        data_source  => $data_source,
        write_source => $write_source,
    );

    if ( $action eq 'task_create' ) {
        $self->_create_task( $cgi, $model );
    }
    elsif ( $action eq 'task_toggle' ) {
        $self->_toggle_task( $cgi, $model );
    }
    elsif ( $action eq 'task_delete' ) {
        $self->_delete_task( $cgi, $model );
    }
    elsif ( $action eq 'set_source' ) {
        $self->_set_source( $cgi, $session );
    }
    else {
        $self->_list_tasks( $cgi, $session, $model );
    }
}

sub _list_tasks {
    my ( $self, $cgi, $session, $model ) = @_;
    my $username   = $session->param('username');
    my $tasks      = eval { $model->list_tasks() } // [];
    my $error      = $@ ? "$@" : undef;
  my $data_source = MultiApp::Util::SessionManager::get_data_source($session) // 'sqlite';

    print $cgi->header('text/html');
    print MultiApp::View::TaskView::render_task_dashboard(
        username    => $username,
        tasks       => $tasks,
        data_source => $data_source,
        error       => $error,
    );
}

sub _create_task {
    my ( $self, $cgi, $model ) = @_;
    my $title = $cgi->param('title') // '';
    eval { $model->create_task($title) };
    $logger->warn("Create task failed: $@") if $@;

    print $cgi->redirect('index.cgi?action=tasks_list');
}

sub _toggle_task {
    my ( $self, $cgi, $model ) = @_;
    my $id        = $cgi->param('id');
    my $source    = $cgi->param('source');
    my $completed = $cgi->param('completed');

    eval { $model->toggle_task( $id, $source, $completed ) };
    $logger->warn("Toggle task failed: $@") if $@;

    print $cgi->redirect('index.cgi?action=tasks_list');
}

sub _delete_task {
    my ( $self, $cgi, $model ) = @_;
    my $id     = $cgi->param('id');
    my $source = $cgi->param('source');

    eval { $model->delete_task( $id, $source ) };
    $logger->warn("Delete task failed: $@") if $@;

    print $cgi->redirect('index.cgi?action=tasks_list');
}

sub _set_source {
    my ( $self, $cgi, $session ) = @_;
    my $source = $cgi->param('source') // 'sqlite';
    my %valid  = map { $_ => 1 } qw(sqlite mariadb api aggregate);
    $source = 'sqlite' unless $valid{$source};

    MultiApp::Util::SessionManager::set_data_source( $session, $source );
    print $cgi->redirect('index.cgi?action=tasks_list');
}

1;
