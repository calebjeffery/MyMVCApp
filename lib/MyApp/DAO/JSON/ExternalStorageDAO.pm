package MyApp::DAO::JSON::ExternalStorageDAO;

use strict;
use warnings;
use MyApp::DAO::JSON::JsonFileDAO;
use Log::Log4perl;

my $logger = Log::Log4perl->get_logger(__PACKAGE__);

sub new {
    my ($class, $dir) = @_;
    die 'Directory not provided' unless $dir;

    my $json_file_dao = MyApp::DAO::JSON::JsonFileDAO->new($dir);
    my $file_name = 'external_storage.json';

    unless (-e $json_file_dao->_get_file_path($file_name)) {
        $json_file_dao->write_json($file_name, { records => {} });
    }

    my $self = {
        json_file_dao => $json_file_dao,
        file_name     => $file_name,
        data          => $json_file_dao->read_json($file_name),
    };

    return bless $self, $class;
}

sub _save {
    my ($self) = @_;
    $self->{json_file_dao}->write_json($self->{file_name}, $self->{data});
}

sub create_record {
    my ($self, $record) = @_;
    die 'Record id required' unless $record->{id};

    $self->{data}{records}{ $record->{id} } = $record;
    $self->_save();
    $logger->debug("Created external storage record: $record->{id}");
    return $record;
}

sub get_record {
    my ($self, $id) = @_;
    return $self->{data}{records}{$id};
}

sub update_record {
    my ($self, $id, $updates) = @_;
    my $record = $self->get_record($id);
    return undef unless $record;

    for my $key (keys %$updates) {
        $record->{$key} = $updates->{$key};
    }

    $self->_save();
    return $record;
}

sub delete_record {
    my ($self, $id) = @_;
    return 0 unless exists $self->{data}{records}{$id};

    delete $self->{data}{records}{$id};
    $self->_save();
    $logger->debug("Deleted external storage record: $id");
    return 1;
}

sub list_records {
    my ($self) = @_;
    my @records = values %{ $self->{data}{records} || {} };
    return \@records;
}

1;
