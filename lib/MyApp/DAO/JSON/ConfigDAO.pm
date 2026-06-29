package MyApp::DAO::JSON::ConfigDAO;

use strict;
use warnings;
use JSON::MaybeXS qw(decode_json);
use MyApp::DAO::JSON::JsonFileDAO;
use Log::Log4perl;

my $logger = Log::Log4perl->get_logger(__PACKAGE__);

sub new {
    my ($class, $config_path) = @_;
    die 'Config path not provided' unless $config_path;

    my $json_file_dao = MyApp::DAO::JSON::JsonFileDAO->new($config_path);
    my $file_name = 'config.json';

    unless (-e $json_file_dao->_get_file_path($file_name)) {
        $json_file_dao->write_json($file_name, {});
    }

    my $config_data = $json_file_dao->read_json($file_name);

    my $self = {
        json_file_dao => $json_file_dao,
        config_data   => $config_data,
        config_path   => $config_path,
        file_name     => $file_name,
    };

    return bless $self, $class;
}

sub get_file_name {
    my ($self) = @_;
    return $self->{file_name};
}

sub set_file_name {
    my ($self, $file_name) = @_;
    $self->{file_name} = $file_name;
}

sub get_config {
    my ($self) = @_;
    return $self->{config_data};
}

sub set_config {
    my ($self, $config_data) = @_;

    my $decoded_config = ref $config_data ? $config_data : decode_json($config_data);
    $self->{config_data} = $decoded_config;
    $self->save();
}

sub load {
    my ($self) = @_;
    $self->{config_data} = $self->{json_file_dao}->read_json($self->{file_name});
    return $self->{config_data};
}

sub save {
    my ($self) = @_;
    $self->{json_file_dao}->write_json($self->{file_name}, $self->{config_data});
}

sub get_value {
    my ($self, $key) = @_;

    my @keys = split /\./, $key;
    my $current_level = $self->{config_data};

    foreach my $k (@keys) {
        return undef unless ref($current_level) eq 'HASH' && exists $current_level->{$k};
        $current_level = $current_level->{$k};
    }

    return $current_level;
}

sub set_value {
    my ($self, $key, $value) = @_;

    my @keys = split /\./, $key;
    my $current_level = $self->{config_data};

    while (@keys > 1) {
        my $k = shift @keys;
        $current_level->{$k} //= {};
        $current_level = $current_level->{$k};
    }

    $current_level->{ $keys[0] } = $value;
    $self->save();
}

sub to_String {
    my ($self) = @_;
    my $json = JSON::MaybeXS->new( utf8 => 1, pretty => 1, canonical => 1 );
    return $json->encode( $self->{config_data} );
}

sub to_String_raw {
    my ($self) = @_;
    return JSON::MaybeXS->new(utf8 => 1)->encode($self->{config_data});
}

1;
