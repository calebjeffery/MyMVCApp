package MultiApp::DAO::JSON::JsonFileDAO;

use strict;
use warnings;
use JSON::MaybeXS;
use File::Spec;
use Log::Log4perl;

my $logger = Log::Log4perl->get_logger(__PACKAGE__);

sub new {
    my ( $class, $dir ) = @_;
    die 'Directory not provided' unless $dir;

    my $self = { directory => $dir };
    bless $self, $class;
    return $self;
}

sub read_json {
    my ( $self, $file_name ) = @_;
    my $file_path = $self->_get_file_path($file_name);

    if ( -e $file_path ) {
        open my $fh, '<:encoding(utf8)', $file_path or die "Cannot open file $file_path: $!";
        local $/;
        my $json_string = <$fh>;
        close $fh;

        return JSON::MaybeXS->new( utf8 => 1 )->decode($json_string);
    }

    return {};
}

sub write_json {
    my ( $self, $file_name, $data ) = @_;
    my $file_path = $self->_get_file_path($file_name);

    my $json        = JSON::MaybeXS->new( utf8 => 1, canonical => 1 );
    my $json_string = $json->encode($data);

    open my $fh, '>:encoding(utf8)', $file_path or die "Cannot open file $file_path: $!";
    print $fh $json_string;
    close $fh;
}

sub _get_file_path {
    my ( $self, $file_name ) = @_;
    return File::Spec->catfile( $self->{directory}, $file_name );
}

1;
