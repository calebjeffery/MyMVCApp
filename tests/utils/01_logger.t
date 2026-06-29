use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Test::More;
use MyApp::Util::Bootstrap;
use Log::Log4perl;

sub example_subroutine {
    my ($logger) = @_;
    $logger->info('This is an info message');
    $logger->warn('This is a warning message');
}

subtest 'Example subtest' => sub {
    plan tests => 1;

    my $logger = Log::Log4perl->get_logger();
    example_subroutine($logger);

    ok( 1, 'Sample test passed' );
};

done_testing();
