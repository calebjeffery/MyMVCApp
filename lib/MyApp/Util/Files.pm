package MyApp::Util::Files;

use strict;
use warnings;
use FindBin;
use File::Spec;
use Cwd qw(abs_path);

sub get_relative_path {
    my ($relative_path) = @_;
    my $current_dir = abs_path($FindBin::Bin) || $FindBin::Bin;
    return _find_file( $current_dir, $relative_path );
}

sub get_project_root {
    my $marker = get_relative_path('cpanfile');
    return undef unless $marker;

    return abs_path( File::Spec->catdir( $marker, File::Spec->updir() ) );
}

sub _find_file {
    my ( $dir, $filename ) = @_;

    my $abs_path = abs_path( File::Spec->catfile( $dir, $filename ) );
    return $abs_path if defined $abs_path && -e $abs_path;

    my $parent_dir = abs_path( File::Spec->catdir( $dir, File::Spec->updir() ) );
    return undef unless defined $parent_dir && $parent_dir ne $dir;

    return _find_file( $parent_dir, $filename );
}

1;
