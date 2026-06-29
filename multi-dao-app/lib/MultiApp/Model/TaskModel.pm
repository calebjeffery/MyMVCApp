package MultiApp::Model::TaskModel;

use strict;
use warnings;
use MultiApp::DAO::Factory;
use Log::Log4perl;

my $logger = Log::Log4perl->get_logger(__PACKAGE__);

sub new {
    my ( $class, %args ) = @_;
    return bless {
        factory      => $args{factory} // MultiApp::DAO::Factory->instance(),
        data_source  => $args{data_source},
        write_source => $args{write_source},
    }, $class;
}

sub _dao {
    my ($self) = @_;
    return $self->{factory}->get_task_dao( $self->{data_source}, $self->{write_source} );
}

sub list_tasks {
    my ($self) = @_;
    my $dao = $self->_dao();
    return $dao->find_all();
}

sub create_task {
    my ( $self, $title ) = @_;
    return undef unless defined $title && $title ne '';

    my $dao = $self->_dao();
    return $dao->create( { title => $title, completed => 0 } );
}

sub toggle_task {
    my ( $self, $id, $source, $completed ) = @_;
    my $dao = $self->_dao();

    my $task = $dao->find_by_id( $id, $source );
    return undef unless $task;

    return $dao->update(
        $id,
        {
            title     => $task->{title},
            completed => $completed ? 0 : 1,
            source    => $source // $task->{source},
        }
    );
}

sub delete_task {
    my ( $self, $id, $source ) = @_;
    my $dao = $self->_dao();
    return $dao->delete( $id, $source );
}

1;
