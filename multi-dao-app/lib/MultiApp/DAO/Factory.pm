package MultiApp::DAO::Factory;

use strict;
use warnings;
use File::Spec;
use MultiApp::DAO::JSON::ConfigDAO;
use MultiApp::DAO::SQLite::TaskDAO;
use MultiApp::DAO::MariaDB::TaskDAO;
use MultiApp::DAO::API::TaskDAO;
use MultiApp::DAO::Aggregate::TaskDAO;
use MultiApp::Util::Files;
use Log::Log4perl;

my $logger = Log::Log4perl->get_logger(__PACKAGE__);

my $INSTANCE;

sub instance {
    my ($class) = @_;
    $INSTANCE //= $class->new();
    return $INSTANCE;
}

sub reset_instance {
    $INSTANCE = undef;
}

sub new {
    my ( $class, $config_dao ) = @_;

    unless ($config_dao) {
        my $root = MultiApp::Util::Files::get_project_root()
          or die 'Project root not found';
        my $config_dir = File::Spec->catdir( $root, 'data', 'configuration' );
        $config_dao = MultiApp::DAO::JSON::ConfigDAO->new($config_dir);
    }

    return bless { config => $config_dao, daos => {} }, $class;
}

sub get_config {
    my ($self) = @_;
    return $self->{config};
}

sub get_task_dao {
    my ( $self, $source_override, $write_source ) = @_;
    my $source = $source_override // $self->{config}->get_value('data_source') // 'sqlite';

    if ( $source eq 'aggregate' ) {
        return $self->_get_aggregate_dao($write_source);
    }

    return $self->_get_single_dao($source);
}

sub _get_single_dao {
    my ( $self, $source ) = @_;
    my $cache_key = "task:$source";

    return $self->{daos}{$cache_key} if $self->{daos}{$cache_key};

    my $dao;
    if ( $source eq 'sqlite' ) {
        my $file = $self->_sqlite_file();
        require File::Path;
        my ( $volume, $dirs, $filename ) = File::Spec->splitpath($file);
        File::Path::make_path($dirs) unless -d $dirs;
        $dao = MultiApp::DAO::SQLite::TaskDAO->new( file => $file );
    }
    elsif ( $source eq 'mariadb' ) {
        $dao = MultiApp::DAO::MariaDB::TaskDAO->new(
            dsn      => $self->{config}->get_value('databases.mariadb.dsn'),
            user     => $self->{config}->get_value('databases.mariadb.user'),
            password => $self->{config}->get_value('databases.mariadb.password'),
        );
    }
    elsif ( $source eq 'api' ) {
        $dao = MultiApp::DAO::API::TaskDAO->new(
            base_url => $self->{config}->get_value('api.base_url'),
            resource => $self->{config}->get_value('api.resource'),
            timeout  => $self->{config}->get_value('api.timeout'),
        );
    }
    else {
        die "Unknown data source: $source";
    }

    $self->{daos}{$cache_key} = $dao;
    return $dao;
}

sub _get_aggregate_dao {
    my ( $self, $write_source ) = @_;
    $write_source //= 'sqlite';

    my $cache_key = "task:aggregate:$write_source";
    return $self->{daos}{$cache_key} if $self->{daos}{$cache_key};

    my %daos;
    for my $source (qw(sqlite mariadb api)) {
        eval { $daos{$source} = $self->_get_single_dao($source); };
        if ($@) {
            $logger->warn("Could not initialize $source DAO for aggregate: $@");
        }
    }

    my $dao = MultiApp::DAO::Aggregate::TaskDAO->new(
        daos         => \%daos,
        write_source => $write_source,
    );

    $self->{daos}{$cache_key} = $dao;
    return $dao;
}

sub _sqlite_file {
    my ($self) = @_;
    my $relative = $self->{config}->get_value('databases.sqlite.file') // 'data/sqlite/app.db';
    my $root     = MultiApp::Util::Files::get_project_root()
      or die 'Project root not found';

    return File::Spec->catfile( $root, split m{/}, $relative );
}

1;
