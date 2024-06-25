use strict;
use warnings;
use Test::More;
use lib 'lib';  # Ensure 'lib' is included in @INC
use Log::Log4perl;

# Initialize Log4perl from configuration file
Log::Log4perl->init('data/configuration/log4perl.conf');

# Example subroutine using Log4perl for logging
sub example_subroutine {
    my ($logger) = @_;

    $logger->info("This is an info message");
    $logger->warn("This is a warning message");
}

# Example usage within a test script
subtest 'Example subtest' => sub {
    plan tests => 1;

    # Get the logger instance
    my $logger = Log::Log4perl->get_logger();

    # Example usage of logger
    example_subroutine($logger);

    ok(1, 'Sample test passed');
};

done_testing();
