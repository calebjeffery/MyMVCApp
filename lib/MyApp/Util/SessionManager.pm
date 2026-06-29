package MyApp::Util::SessionManager;

use strict;
use warnings;
use CGI::Session;
use MyApp::Util::Files;
use File::Spec;
use Cwd qw(abs_path);

sub _session_dir {
    my $root = MyApp::Util::Files::get_project_root();
    die 'Project root not found' unless $root;

    my $dir = abs_path( File::Spec->catdir( $root, 'data', 'sessions' ) );
    die 'Session directory not found' unless $dir;

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

1;
