package MyApp::Util::Files;

use strict;
use warnings;
use FindBin;
use File::Spec;

sub get_relative_path {
    my ($relative_path) = @_;
    my $current_dir = $FindBin::Bin;
    my $abs_path = _find_file($current_dir, $relative_path);
    return $abs_path;
}

sub _find_file {
    my ($dir, $filename) = @_;
    my $abs_path = File::Spec->catfile($dir, $filename);
    return $abs_path if -e $abs_path;  # Check if file exists in current directory

    my $parent_dir = File::Spec->catdir($dir, '..');
    return undef if $parent_dir eq $dir;  # Stop if we've reached the root directory
    return _find_file($parent_dir, $filename);  # Recursively search in parent directory
}

1;
