# Load perl main modules
use strict;
use warnings;
use FindBin;
use Test::More;
use File::Spec;

use lib "$FindBin::Bin/../../../lib";
use MyApp::Util::Bootstrap;
use MyApp::Service::FileStorageService;

my $test_root = File::Spec->catdir( $FindBin::Bin, '../../data/test/file_service' );
my $files_dir = File::Spec->catdir( $test_root, 'files' );
my $db_dir    = File::Spec->catdir( $test_root, 'external_storage' );

require File::Path;
File::Path::remove_tree($test_root) if -d $test_root;
File::Path::make_path($files_dir);
File::Path::make_path($db_dir);

my $service = MyApp::Service::FileStorageService->new({
    external_storage_dir => $db_dir,
    file_storage         => {
        default_provider => 'system_io',
        providers        => {
            system_io => { root_dir => $files_dir },
        },
    },
});

subtest 'FileStorageService stores metadata and content' => sub {
    plan tests => 5;

    my $record = $service->store_file({
        content       => 'page attachment content',
        original_name => 'notes.txt',
        mime_type     => 'text/plain',
    });

    ok( $record->{id}, 'record id generated' );
    is( $record->{storage_provider}, 'system_io', 'uses system_io provider' );
    ok( $record->{location_pointer}, 'location pointer stored' );

    my $metadata = $service->get_file_metadata($record->{id});
    is( $metadata->{original_name}, 'notes.txt', 'metadata persisted in external storage table' );

    my $content = $service->fetch_file_content($record->{id});
    is( $content, 'page attachment content', 'content fetched from disk via location pointer' );
};

done_testing();
