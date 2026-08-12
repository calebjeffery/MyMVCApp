package MyApp::DAO::Storage::StorageDAO;

use strict;
use warnings;

# Base contract for file storage backends. Concrete DAOs must implement
# store, fetch, delete, and exists.

sub new {
    my ($class, $config) = @_;
    die 'StorageDAO is abstract' if $class eq __PACKAGE__;
    return bless { config => $config || {} }, $class;
}

sub provider_name {
    die 'provider_name not implemented';
}

sub store {
    my ($self, $location_pointer, $content, $metadata) = @_;
    die 'store not implemented';
}

sub fetch {
    my ($self, $location_pointer) = @_;
    die 'fetch not implemented';
}

sub delete {
    my ($self, $location_pointer) = @_;
    die 'delete not implemented';
}

sub exists {
    my ($self, $location_pointer) = @_;
    die 'exists not implemented';
}

1;
