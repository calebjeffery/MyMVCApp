package MyApp::Model::HomeModel;

use strict;
use warnings;
use Log::Log4perl;

my $logger = Log::Log4perl->get_logger(__PACKAGE__);

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self;
}

sub get_data {
    my $self = shift;
    $logger->info('running get_data');
    return {
        title   => 'My MVC App',
        message => 'Welcome to My MVC App',
    };
}

1;
