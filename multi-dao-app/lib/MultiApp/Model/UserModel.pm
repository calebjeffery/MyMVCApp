package MultiApp::Model::UserModel;

use strict;
use warnings;
use Log::Log4perl;

my $logger = Log::Log4perl->get_logger(__PACKAGE__);

my %users = (
    'alice' => {
        password => 'alice123',
        name     => 'Alice Smith',
    },
    'bob' => {
        password => 'bob456',
        name     => 'Bob Johnson',
    },
);

sub authenticate_user {
    my ( $class, $username, $password ) = @_;
    $logger->debug( 'Authenticating user: ' . ( $username // '(none)' ) );

    return $users{$username}
      if defined $username
      && defined $password
      && exists $users{$username}
      && $users{$username}{password} eq $password;

    return undef;
}

1;
