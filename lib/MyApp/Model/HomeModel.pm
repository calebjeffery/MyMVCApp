package MyApp::Model::HomeModel;

use strict;
use warnings;
use Log::Log4perl;
use MyApp::Util::Files;
# Initialize Log4perl from configuration file
Log::Log4perl->init(MyApp::Util::Files::get_relative_path('data/configuration/log4perl.conf'));
my $logger = Log::Log4perl->get_logger(__PACKAGE__);

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self;
}

sub get_data {
    my $self = shift;
    $logger->info("running get_data");
    return {
        title => 'My MVC App',
        message => 'Welcome to My MVC App',
    };
}

1;
