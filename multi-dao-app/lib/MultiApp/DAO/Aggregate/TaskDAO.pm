package MultiApp::DAO::Aggregate::TaskDAO;

use strict;
use warnings;
use base 'MultiApp::DAO::TaskDAOBase';
use Log::Log4perl;

my $logger = Log::Log4perl->get_logger(__PACKAGE__);

sub new {
    my ( $class, %args ) = @_;
    die 'daos required' unless $args{daos} && ref $args{daos} eq 'HASH';

    return bless {
        daos         => $args{daos},
        write_source => $args{write_source} // 'sqlite',
    }, $class;
}

sub _dao_for_source {
    my ( $self, $source ) = @_;
    return $self->{daos}{$source};
}

sub find_all {
    my ($self) = @_;
    my @all;

    for my $source (qw(sqlite mariadb api)) {
        my $dao = $self->{daos}{$source} or next;
        eval {
            my $tasks = $dao->find_all();
            push @all, @$tasks if $tasks && ref $tasks eq 'ARRAY';
        };
        if ($@) {
            $logger->warn("Aggregate find_all failed for $source: $@");
        }
    }

    return \@all;
}

sub find_by_id {
    my ( $self, $id, $source ) = @_;

    if ($source) {
        my $dao = $self->_dao_for_source($source) or return undef;
        return $dao->find_by_id($id);
    }

    for my $src (qw(sqlite mariadb api)) {
        my $dao = $self->{daos}{$src} or next;
        my $task = eval { $dao->find_by_id($id) };
        return $task if $task;
    }

    return undef;
}

sub create {
    my ( $self, $task ) = @_;
    my $source = $task->{source} // $self->{write_source};
    my $dao    = $self->_dao_for_source($source)
      or die "No DAO available for write source: $source";

    return $dao->create($task);
}

sub update {
    my ( $self, $id, $task ) = @_;
    my $source = $task->{source} or return undef;
    my $dao    = $self->_dao_for_source($source) or return undef;

    return $dao->update( $id, $task );
}

sub delete {
    my ( $self, $id, $source ) = @_;
    $source //= $self->{write_source};

    my $dao = $self->_dao_for_source($source) or return 0;
    return $dao->delete($id);
}

sub set_write_source {
    my ( $self, $source ) = @_;
    $self->{write_source} = $source if $source;
}

1;
