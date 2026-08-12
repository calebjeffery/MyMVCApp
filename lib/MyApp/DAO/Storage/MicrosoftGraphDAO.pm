package MyApp::DAO::Storage::MicrosoftGraphDAO;

use strict;
use warnings;
use parent 'MyApp::DAO::Storage::StorageDAO';
use Log::Log4perl;

my $logger = Log::Log4perl->get_logger(__PACKAGE__);

sub provider_name {
    return 'microsoft_graph';
}

sub store {
    my ($self, $location_pointer, $content, $metadata) = @_;
    my $drive_id = $self->{config}{drive_id}
        or die 'microsoft_graph drive_id not configured';

    $logger->info("Microsoft Graph store: drive=$drive_id path=$location_pointer");
    die 'Microsoft Graph integration not configured (set tenant, client_id, and credentials)'
        unless $self->{config}{enabled};

    return "graph://$drive_id/$location_pointer";
}

sub fetch {
    my ($self, $location_pointer) = @_;
    my $drive_id = $self->{config}{drive_id}
        or die 'microsoft_graph drive_id not configured';

    $logger->info("Microsoft Graph fetch: drive=$drive_id path=$location_pointer");
    die 'Microsoft Graph integration not configured (set tenant, client_id, and credentials)'
        unless $self->{config}{enabled};

    return '';
}

sub delete {
    my ($self, $location_pointer) = @_;
    my $drive_id = $self->{config}{drive_id}
        or die 'microsoft_graph drive_id not configured';

    $logger->info("Microsoft Graph delete: drive=$drive_id path=$location_pointer");
    die 'Microsoft Graph integration not configured (set tenant, client_id, and credentials)'
        unless $self->{config}{enabled};

    return 1;
}

sub exists {
    my ($self, $location_pointer) = @_;
    return 0 unless $self->{config}{enabled};
    return 0;
}

1;
