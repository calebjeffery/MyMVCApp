package MyApp::DAO::Storage::SystemIODAO;

use strict;
use warnings;
use parent 'MyApp::DAO::Storage::StorageDAO';
use File::Spec;
use File::Path qw(make_path);
use File::Basename qw(dirname);
use Log::Log4perl;

my $logger = Log::Log4perl->get_logger(__PACKAGE__);

sub provider_name {
    return 'system_io';
}

sub store {
    my ($self, $location_pointer, $content) = @_;
    my $root = $self->{config}{root_dir}
        or die 'system_io root_dir not configured';

    my $full_path = File::Spec->catfile($root, $location_pointer);
    my $dir = dirname($full_path);
    make_path($dir) unless -d $dir;

    open my $fh, '>', $full_path or die "Cannot write $full_path: $!";
    binmode $fh;
    print $fh $content;
    close $fh;

    $logger->debug("Stored file at $full_path");
    return $full_path;
}

sub fetch {
    my ($self, $location_pointer) = @_;
    my $root = $self->{config}{root_dir}
        or die 'system_io root_dir not configured';

    my $full_path = File::Spec->catfile($root, $location_pointer);
    die "File not found: $full_path" unless -e $full_path;

    open my $fh, '<', $full_path or die "Cannot read $full_path: $!";
    binmode $fh;
    local $/;
    my $content = <$fh>;
    close $fh;

    return $content;
}

sub delete {
    my ($self, $location_pointer) = @_;
    my $root = $self->{config}{root_dir}
        or die 'system_io root_dir not configured';

    my $full_path = File::Spec->catfile($root, $location_pointer);
    return 0 unless -e $full_path;

    unlink $full_path or die "Cannot delete $full_path: $!";
    $logger->debug("Deleted file at $full_path");
    return 1;
}

sub exists {
    my ($self, $location_pointer) = @_;
    my $root = $self->{config}{root_dir}
        or die 'system_io root_dir not configured';

    my $full_path = File::Spec->catfile($root, $location_pointer);
    return -e $full_path ? 1 : 0;
}

1;
