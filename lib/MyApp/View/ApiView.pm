package MyApp::View::ApiView;

use strict;
use warnings;
use JSON::MaybeXS;

sub render_json {
    my ($data, $status) = @_;
    $status ||= 200;

    my $json = JSON::MaybeXS->new(utf8 => 1, canonical => 1)->encode($data);
    print "Status: $status\n";
    print "Content-Type: application/json; charset=utf-8\n\n";
    print $json;
}

sub render_error {
    my ($message, $status) = @_;
    $status ||= 400;
    render_json({ error => $message }, $status);
}

sub render_file {
    my ($content, $mime_type, $filename) = @_;
    $mime_type ||= 'application/octet-stream';

    print "Content-Type: $mime_type\n";
    if ($filename) {
        print "Content-Disposition: inline; filename=\"$filename\"\n";
    }
    print "\n";
    binmode STDOUT;
    print $content;
}

1;
