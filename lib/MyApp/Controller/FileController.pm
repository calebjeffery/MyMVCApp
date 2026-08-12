package MyApp::Controller::FileController;

use strict;
use warnings;
use CGI;
use MyApp::Model::FileModel;
use MyApp::View::ApiView;
use Log::Log4perl;

my $logger = Log::Log4perl->get_logger(__PACKAGE__);

sub new {
    my ($class) = @_;
    return bless { model => MyApp::Model::FileModel->new() }, $class;
}

sub handle_request {
    my ($self) = @_;
    my $cgi = CGI->new;
    my $action = $cgi->param('action') || '';

    if ($ENV{REQUEST_METHOD} eq 'OPTIONS') {
        $self->_print_cors_headers($cgi);
        print "Content-Type: text/plain\n\n";
        return;
    }

    eval {
        if ($action eq 'file') {
            $self->_handle_file($cgi);
        } elsif ($action eq 'upload') {
            $self->_handle_upload($cgi);
        } elsif ($action eq 'list') {
            $self->_handle_list($cgi);
        } else {
            MyApp::View::ApiView::render_error('Unknown action', 404);
        }
    };
    if ($@) {
        $logger->error("API error: $@");
        MyApp::View::ApiView::render_error("$@", 500);
    }
}

sub _handle_file {
    my ($self, $cgi) = @_;
    my $id = $cgi->param('id');
    return MyApp::View::ApiView::render_error('Missing id parameter', 400) unless $id;

    if ($ENV{REQUEST_METHOD} eq 'DELETE') {
        my $deleted = $self->{model}->delete_file($id);
        return MyApp::View::ApiView::render_error('File not found', 404) unless $deleted;
        return MyApp::View::ApiView::render_json({ success => 1, id => $id });
    }

    my $metadata = $self->{model}->get_metadata($id);
    return MyApp::View::ApiView::render_error('File not found', 404) unless $metadata;

    my $download = $cgi->param('download');
    if ($download) {
        my $content = $self->{model}->get_content($id);
        return MyApp::View::ApiView::render_file(
            $content,
            $metadata->{mime_type},
            $metadata->{original_name},
        );
    }

    MyApp::View::ApiView::render_json({ file => $metadata });
}

sub _handle_upload {
    my ($self, $cgi) = @_;
    return MyApp::View::ApiView::render_error('POST required', 405)
        unless $ENV{REQUEST_METHOD} eq 'POST';

    my $upload = $cgi->upload('file');
    return MyApp::View::ApiView::render_error('No file uploaded', 400) unless $upload;

    open my $fh, '<', $upload or return MyApp::View::ApiView::render_error('Cannot read upload', 500);
    binmode $fh;
    local $/;
    my $content = <$fh>;
    close $fh;

    my $original_name = $cgi->uploadInfo($upload)->{'Content-Disposition'};
    if ($original_name && $original_name =~ /filename="([^"]+)"/) {
        $original_name = $1;
    } else {
        $original_name = $cgi->param('filename') || 'upload.bin';
    }

    my $mime_type = $cgi->uploadInfo($upload)->{'Content-Type'}
        || $cgi->param('mime_type')
        || 'application/octet-stream';

    my $provider = $cgi->param('provider');

    my $record = $self->{model}->upload_file({
        content       => $content,
        original_name => $original_name,
        mime_type     => $mime_type,
        provider      => $provider,
    });

    MyApp::View::ApiView::render_json({ file => $record }, 201);
}

sub _handle_list {
    my ($self, $cgi) = @_;
    my $files = $self->{model}->list_files();
    MyApp::View::ApiView::render_json({ files => $files });
}

sub _print_cors_headers {
    my ($self, $cgi) = @_;
    print "Access-Control-Allow-Origin: *\n";
    print "Access-Control-Allow-Methods: GET, POST, DELETE, OPTIONS\n";
    print "Access-Control-Allow-Headers: Content-Type\n";
}

1;
