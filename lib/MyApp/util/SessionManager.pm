package MyApp::Util::SessionManager;

use strict;
use warnings;
use CGI::Session;
use MyApp::Util::Files;

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;

    my $session_dir = MyApp::Util::Files::get_relative_path('data/sessions');
    $self->{session} = CGI::Session->new(undef, undef, { Directory => $session_dir });

    return $self;
}

sub is_session_valid {
    my ($self, $session) = @_;

    return 0 unless $session && ref $session && $session->isa('CGI::Session');
    
    # Example: Check if session is expired
    if ($session->is_expired) {
        $session->delete();  # Optional: Delete expired session
        return 0;
    }

    # Example: Check for required session parameters (e.g., username)
    my $username = $session->param('username');
    return 0 unless $username;  # Ensure username exists in session

    # Additional validation logic can be added here

    return 1;  # Session is valid
}

sub get_session {
    my $self = shift;

    # Example: Retrieve existing session or create a new one
    my $session = CGI::Session->new() or die CGI::Session->errstr;
    return $session;
}

sub create_session {
    my ($self, $username) = @_;

    my $session = $self->get_session();
    $session->param('username', $username);  # Store username in session

    # Additional session initialization logic can be added here

    return $session;  # Return the created session
}
1;
