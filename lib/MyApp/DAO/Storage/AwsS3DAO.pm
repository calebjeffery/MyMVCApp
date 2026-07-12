package MyApp::DAO::Storage::AwsS3DAO;

use strict;
use warnings;
use parent 'MyApp::DAO::Storage::StorageDAO';
use Log::Log4perl;

my $logger = Log::Log4perl->get_logger(__PACKAGE__);

sub provider_name {
    return 'aws_s3';
}

sub store {
    my ($self, $location_pointer, $content, $metadata) = @_;
    my $bucket = $self->{config}{bucket}
        or die 'aws_s3 bucket not configured';

    $logger->info("AWS S3 store: s3://$bucket/$location_pointer");
    die 'AWS S3 integration not configured (install Paws::S3 and set credentials)'
        unless $self->{config}{enabled};

    return "s3://$bucket/$location_pointer";
}

sub fetch {
    my ($self, $location_pointer) = @_;
    my $bucket = $self->{config}{bucket}
        or die 'aws_s3 bucket not configured';

    $logger->info("AWS S3 fetch: s3://$bucket/$location_pointer");
    die 'AWS S3 integration not configured (install Paws::S3 and set credentials)'
        unless $self->{config}{enabled};

    return '';
}

sub delete {
    my ($self, $location_pointer) = @_;
    my $bucket = $self->{config}{bucket}
        or die 'aws_s3 bucket not configured';

    $logger->info("AWS S3 delete: s3://$bucket/$location_pointer");
    die 'AWS S3 integration not configured (install Paws::S3 and set credentials)'
        unless $self->{config}{enabled};

    return 1;
}

sub exists {
    my ($self, $location_pointer) = @_;
    return 0 unless $self->{config}{enabled};
    return 0;
}

1;
