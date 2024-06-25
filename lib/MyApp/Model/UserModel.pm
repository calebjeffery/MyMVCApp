package MyApp::Model::UserModel;
use strict;
use warnings;
use Log::Log4perl;
use MyApp::Util::Files;
# Initialize Log4perl from configuration file
Log::Log4perl->init(MyApp::Util::Files::get_relative_path('data/configuration/log4perl.conf'));
my $logger = Log::Log4perl->get_logger(__PACKAGE__);

# Mock user database (replace with actual database integration)
my %users = (
    'alice' => {
        password => 'alice123',
        name     => 'Alice Smith'
    },
    'bob' => {
        password => 'bob456',
        name     => 'Bob Johnson'
    }
);

# Method to authenticate user
sub authenticate_user {
    my ($class, $username, $password) = @_;
    $logger->debug("Authenticating User:".$username." Password:".$password);
    return $users{$username} if exists $users{$username} && $users{$username}{password} eq $password;
    return undef;
}
1;
