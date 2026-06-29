package MultiApp::DAO::SQLite::TaskDAO;

use strict;
use warnings;
use base 'MultiApp::DAO::TaskDAOBase';
use DBI;
use MultiApp::Util::Files;
use Log::Log4perl;

my $logger = Log::Log4perl->get_logger(__PACKAGE__);

sub new {
    my ( $class, %args ) = @_;

    my $file = $args{file} // ':memory:';
    my $dbh  = DBI->connect(
        "dbi:SQLite:dbname=$file",
        '',
        '',
        {
            RaiseError     => 1,
            AutoCommit     => 1,
            sqlite_unicode => 1,
        }
    ) or die $DBI::errstr;

    my $self = {
        dbh    => $dbh,
        source => 'sqlite',
    };
    bless $self, $class;

    $self->_init_schema unless $args{skip_schema};

    return $self;
}

sub _init_schema {
    my ($self) = @_;
    my $sql = MultiApp::Util::Files::read_sql_file('sql/sqlite/schema.sql');
    $self->{dbh}->do($sql);
}

sub find_all {
    my ($self) = @_;
    my $sth = $self->{dbh}->prepare('SELECT id, title, completed FROM tasks ORDER BY id');
    $sth->execute();

    my @tasks;
    while ( my $row = $sth->fetchrow_hashref ) {
        push @tasks, $self->_with_source( $row, $self->{source} );
    }

    return \@tasks;
}

sub find_by_id {
    my ( $self, $id ) = @_;
    my $sth = $self->{dbh}->prepare('SELECT id, title, completed FROM tasks WHERE id = ?');
    $sth->execute($id);
    my $row = $sth->fetchrow_hashref;

    return $row ? $self->_with_source( $row, $self->{source} ) : undef;
}

sub create {
    my ( $self, $task ) = @_;
    my $data = $self->_normalize_input($task);

    my $sth = $self->{dbh}->prepare('INSERT INTO tasks (title, completed) VALUES (?, ?)');
    $sth->execute( $data->{title}, $data->{completed} );

    my $id = $self->{dbh}->last_insert_id( undef, undef, 'tasks', 'id' );
    return $self->find_by_id($id);
}

sub update {
    my ( $self, $id, $task ) = @_;
    return undef unless $self->find_by_id($id);

    my $data = $self->_normalize_input($task);
    my $sth  = $self->{dbh}->prepare('UPDATE tasks SET title = ?, completed = ? WHERE id = ?');
    $sth->execute( $data->{title}, $data->{completed}, $id );

    return $self->find_by_id($id);
}

sub delete {
    my ( $self, $id ) = @_;
    my $sth = $self->{dbh}->prepare('DELETE FROM tasks WHERE id = ?');
    $sth->execute($id);
    return $sth->rows > 0 ? 1 : 0;
}

1;
