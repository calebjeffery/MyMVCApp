package MyApp::Model::FileModel;

use strict;
use warnings;
use MyApp::Service::FileStorageService;
use Log::Log4perl;

my $logger = Log::Log4perl->get_logger(__PACKAGE__);

sub new {
    my ($class) = @_;
    my $self = {
        storage_service => MyApp::Service::FileStorageService->new(),
    };
    return bless $self, $class;
}

sub upload_file {
    my ($self, $args) = @_;
    $logger->debug('Uploading file: ' . ($args->{original_name} || 'unnamed'));
    return $self->{storage_service}->store_file($args);
}

sub get_metadata {
    my ($self, $id) = @_;
    return $self->{storage_service}->get_file_metadata($id);
}

sub get_content {
    my ($self, $id) = @_;
    return $self->{storage_service}->fetch_file_content($id);
}

sub delete_file {
    my ($self, $id) = @_;
    return $self->{storage_service}->delete_file($id);
}

sub list_files {
    my ($self) = @_;
    return $self->{storage_service}->list_files();
}

1;
