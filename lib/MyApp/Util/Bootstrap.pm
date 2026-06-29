package MyApp::Util::Bootstrap;

use strict;
use warnings;
use Log::Log4perl;
use MyApp::Util::Files;
use File::Spec;
use Cwd qw(abs_path);

our $INITIALIZED;

sub init_logging {
    return if $INITIALIZED;

    my $log_file;
    my $root = MyApp::Util::Files::get_project_root();
    if ($root) {
        $log_file = abs_path( File::Spec->catfile( $root, 'logs', 'myapp.log' ) );
        my $log_dir = abs_path( File::Spec->catdir( $root, 'logs' ) );
        require File::Path;
        File::Path::make_path($log_dir) unless -d $log_dir;
    }

    Log::Log4perl->init(
        {
            'log4perl.rootLogger'                             => 'DEBUG, File, Screen',
            'log4perl.appender.File'                          => 'Log::Log4perl::Appender::File',
            'log4perl.appender.File.filename'                 => ( $log_file || 'logs/myapp.log' ),
            'log4perl.appender.File.mode'                     => 'append',
            'log4perl.appender.File.layout'                 => 'Log::Log4perl::Layout::PatternLayout',
            'log4perl.appender.File.layout.ConversionPattern' => '[%d] [%p] %F{1}:%L - %m%n',
            'log4perl.appender.Screen'                        => 'Log::Log4perl::Appender::Screen',
            'log4perl.appender.Screen.stderr'                 => 1,
            'log4perl.appender.Screen.layout'               => 'Log::Log4perl::Layout::PatternLayout',
            'log4perl.appender.Screen.layout.ConversionPattern' => '[%d] [%p] %m%n',
            'log4perl.logger.MyApp'                           => 'DEBUG',
        }
    );

    $INITIALIZED = 1;
}

init_logging();

1;
