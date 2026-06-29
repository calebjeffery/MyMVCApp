package MultiApp::DAO::TaskDAOBase;

use strict;
use warnings;

# Interface: find_all, find_by_id, create, update, delete

sub _with_source {
    my ( $self, $task, $source ) = @_;
    return {
        id        => $task->{id},
        title     => $task->{title},
        completed => $task->{completed} ? 1 : 0,
        source    => $source,
    };
}

sub _normalize_input {
    my ( $self, $task ) = @_;
    return {
        title     => $task->{title} // '',
        completed => $task->{completed} ? 1 : 0,
    };
}

1;
