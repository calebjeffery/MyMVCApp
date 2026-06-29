package MultiApp::Util::SessionManager;

use strict;
use warnings;
use CGI::Session;
use MultiApp::Util::Files;
use File::Spec;
use Cwd qw(abs_path);

sub _session_dir {
    my $root = MultiApp::Util::Files::get_project_root();
    die 'Project root not found' unless $root;

    my $dir = abs_path( File::Spec->catdir( $root, 'data', 'sessions' ) );

    require File::Path;
    File::Path::make_path($dir) unless -d $dir;

    return $dir;
}

sub get_session {
    my ($cgi) = @_;
    die 'CGI object required' unless $cgi;

    return CGI::Session->new( undef, $cgi, { Directory => _session_dir() } );
}

sub create_session {
    my ( $cgi, $username ) = @_;
    die 'CGI object required' unless $cgi;

    my $session = get_session($cgi);
    $session->param( 'username', $username );
    $session->flush();

    return $session;
}

sub is_session_valid {
    my ($session) = @_;

    return 0 unless $session && ref $session && $session->isa('CGI::Session');

    if ( $session->is_expired ) {
        $session->delete();
        return 0;
    }

    my $username = $session->param('username');
    return 0 unless $username;

    return 1;
}

sub get_data_source {
    my ($session) = @_;
    return $session ? $session->param('data_source') : undef;
}

sub set_data_source {
    my ( $session, $source ) = @_;
    return unless $session && $source;

    $session->param( 'data_source', $source );
    $session->flush();
}

1;
