package MyApp::Service::FileStorageService;

use strict;
use warnings;
use MyApp::DAO::Storage::SystemIODAO;
use MyApp::DAO::Storage::AwsS3DAO;
use MyApp::DAO::Storage::MicrosoftGraphDAO;
use MyApp::DAO::JSON::ExternalStorageDAO;
use MyApp::Util::Files;
use File::Spec;
use File::Basename qw(basename);
use Time::Piece;
use Digest::SHA qw(sha256_hex);
use Log::Log4perl;

my $logger = Log::Log4perl->get_logger(__PACKAGE__);

my %PROVIDER_CLASSES = (
    system_io        => 'MyApp::DAO::Storage::SystemIODAO',
    aws_s3           => 'MyApp::DAO::Storage::AwsS3DAO',
    microsoft_graph  => 'MyApp::DAO::Storage::MicrosoftGraphDAO',
);

sub new {
    my ($class, $config) = @_;
    $config ||= _load_config();

    my $root = MyApp::Util::Files::get_project_root();
    my $storage_dir = $config->{external_storage_dir} || 'data/external_storage';
    unless (File::Spec->file_name_is_absolute($storage_dir)) {
        $storage_dir = File::Spec->catdir($root, $storage_dir);
    }

    my $self = {
        config                => $config,
        external_storage_dao  => MyApp::DAO::JSON::ExternalStorageDAO->new($storage_dir),
        storage_daos          => {},
    };

    return bless $self, $class;
}

sub _load_config {
    my $root = MyApp::Util::Files::get_project_root();
    my $config_path = File::Spec->catdir($root, 'data', 'configuration');
    require MyApp::DAO::JSON::ConfigDAO;
    my $config_dao = MyApp::DAO::JSON::ConfigDAO->new($config_path);
    return $config_dao->get_config();
}

sub _get_storage_dao {
    my ($self, $provider) = @_;
    $provider ||= $self->{config}{file_storage}{default_provider} || 'system_io';

    return $self->{storage_daos}{$provider} if $self->{storage_daos}{$provider};

    my $class = $PROVIDER_CLASSES{$provider}
        or die "Unknown storage provider: $provider";

    my $provider_config = { %{ $self->{config}{file_storage}{providers}{$provider} || {} } };
    if ($provider eq 'system_io' && $provider_config->{root_dir} && !File::Spec->file_name_is_absolute($provider_config->{root_dir})) {
        my $root = MyApp::Util::Files::get_project_root();
        $provider_config->{root_dir} = File::Spec->catdir($root, $provider_config->{root_dir});
    }
    my $dao = $class->new($provider_config);
    $self->{storage_daos}{$provider} = $dao;
    return $dao;
}

sub store_file {
    my ($self, $args) = @_;
    my $content       = $args->{content};
    my $original_name = $args->{original_name} || 'unnamed';
    my $mime_type     = $args->{mime_type}     || 'application/octet-stream';
    my $provider      = $args->{provider};
    my $metadata      = $args->{metadata}      || {};

    die 'File content required' unless defined $content;

    my $storage_dao = $self->_get_storage_dao($provider);
    my $provider_name = $storage_dao->provider_name;

    my $id = _generate_id($content, $original_name);
    my $location_pointer = _build_location_pointer($id, $original_name);

    $storage_dao->store($location_pointer, $content, {
        original_name => $original_name,
        mime_type     => $mime_type,
        %$metadata,
    });

    my $now = localtime->datetime;
    my $record = {
        id                => $id,
        original_name     => $original_name,
        mime_type         => $mime_type,
        size              => length($content),
        storage_provider  => $provider_name,
        location_pointer  => $location_pointer,
        metadata          => $metadata,
        created_at        => $now,
        updated_at        => $now,
    };

    $self->{external_storage_dao}->create_record($record);
    $logger->info("Stored file $id via $provider_name at $location_pointer");
    return $record;
}

sub get_file_metadata {
    my ($self, $id) = @_;
    return $self->{external_storage_dao}->get_record($id);
}

sub fetch_file_content {
    my ($self, $id) = @_;
    my $record = $self->get_file_metadata($id)
        or die "File record not found: $id";

    my $storage_dao = $self->_get_storage_dao($record->{storage_provider});
    return $storage_dao->fetch($record->{location_pointer});
}

sub delete_file {
    my ($self, $id) = @_;
    my $record = $self->get_file_metadata($id)
        or return 0;

    my $storage_dao = $self->_get_storage_dao($record->{storage_provider});
    $storage_dao->delete($record->{location_pointer});
    $self->{external_storage_dao}->delete_record($id);
    $logger->info("Deleted file $id");
    return 1;
}

sub list_files {
    my ($self) = @_;
    return $self->{external_storage_dao}->list_records();
}

sub _generate_id {
    my ($content, $original_name) = @_;
    my $seed = sha256_hex($content . $original_name . time() . rand());
    return substr($seed, 0, 32);
}

sub _build_location_pointer {
    my ($id, $original_name) = @_;
    my $safe_name = $original_name;
    $safe_name =~ s/[^A-Za-z0-9._-]+/_/g;
    my $t = localtime;
    my $date_path = sprintf('%04d/%02d', $t->year + 1900, $t->mon + 1);
    return File::Spec->catfile($date_path, $id, $safe_name);
}

1;
