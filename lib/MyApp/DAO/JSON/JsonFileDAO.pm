package MyApp::DAO::JSON::JsonFileDAO;

use strict;
use warnings;
use JSON::MaybeXS;
use File::Spec;
use Log::Log4perl;
Log::Log4perl->init('data/configuration/log4perl.conf');
# Get the logger instance
my $logger = Log::Log4perl->get_logger();

sub new {
    my ($class, $dir) = @_;
    die "Directory not provided" unless $dir;

    my $self = {
        directory => $dir,
    };

    bless $self, $class;
    return $self;
}

sub read_json {
    my ($self, $file_name) = @_;
    my $file_path = $self->_get_file_path($file_name);

    if (-e $file_path) {
        open my $fh, '<:encoding(utf8)', $file_path or die "Cannot open file $file_path: $!";
        local $/;
        my $json_string = <$fh>;
        close $fh;

        return JSON->new->utf8->decode($json_string);
    } else {
        return {};  # Return an empty hashref if file doesn't exist
    }
}

sub write_json {
    my ($self, $file_name, $data) = @_;
    my $file_path = $self->_get_file_path($file_name);

    my $json = JSON->new->utf8->canonical(1);
    my $json_string = $json->encode($data);

    open my $fh, '>:encoding(utf8)', $file_path or die "Cannot open file $file_path: $!";
    print $fh $json_string;
    close $fh;
}

sub _get_file_path {
    my ($self, $file_name) = @_;
    return File::Spec->catfile($self->{directory}, $file_name);
}

1;  # End of package
