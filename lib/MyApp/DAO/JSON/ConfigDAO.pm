package MyApp::DAO::JSON::ConfigDAO;

use strict;
use warnings;
use JSON::MaybeXS;

# Use JsonFileDAO for file operations
use MyApp::DAO::JSON::JsonFileDAO;
use Log::Log4perl;
Log::Log4perl->init('data/configuration/log4perl.conf');
# Get the logger instance
my $logger = Log::Log4perl->get_logger();

sub new {
    my ($class, $config_path) = @_;
    die "Config path not provided" unless $config_path;

    # Initialize JsonFileDAO for configuration directory
    my $json_file_dao = MyApp::DAO::JSON::JsonFileDAO->new($config_path);

    # Define the configuration file name
    my $file_name = 'config.json';

    # Create the config.json file if it doesn't exist
    unless (-e $json_file_dao->_get_file_path($file_name)) {
        $json_file_dao->write_json($file_name, {});  # Create an empty JSON object
    }

    # Load the configuration from the file
    my $config_data = $json_file_dao->read_json($file_name);

    # Create the object with the configuration data
    my $self = {
        json_file_dao => $json_file_dao,
        config_data   => $config_data,
        config_path   => $config_path,
        file_name => $file_name
    };

    return bless $self, $class;
}
# Method to get the configuration data
sub get_file_name {
    my ($self) = @_;
    return $self->{file_name};
}

# Method to update the configuration data
sub set_file_name {
    my ($self, $file_name) = @_;
    $self->{file_name} = $file_name;    
}
# Method to get the configuration data
sub get_config {
    my ($self) = @_;
    return $self->{config_data};
}

# Method to update the configuration data
sub set_config {
    my ($self, $config_data) = @_;
    # Attempt to decode JSON
    my $decoded_config;
    $decoded_config = decode_json($config_data);
    
    # Assign decoded config to object attribute
    $self->{config_data} = $decoded_config;

    # Save the configuration (assuming this method exists)
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

    # Split the key using dot notation to handle nested structure
    my @keys = split /\./, $key;
    my $current_level = $self->{config_data};

    # Traverse through the nested structure
    foreach my $k (@keys) {
        return undef unless ref($current_level) eq 'HASH' && exists $current_level->{$k};
        $current_level = $current_level->{$k};
    }

    return $current_level;
}


sub set_value {
    my ($self, $key, $value) = @_;

    # Split the key using dot notation to handle nested structure
    my @keys = split /\./, $key;
    my $current_level = $self->{config_data};

    # Traverse through the nested structure
    while (@keys > 1) {
        my $k = shift @keys;
        $current_level->{$k} //= {};  # Ensure the key exists and is initialized as a hashref if not
        $current_level = $current_level->{$k};
    }

    # Set the final value
    $current_level->{ $keys[0] } = $value;

    # Save the updated configuration
    $self->save();
}

sub to_String {
    my ($self) = @_;
    my $json = JSON->new->utf8->pretty->canonical(1)->indent_length(2);
    return $json->encode($self->{config_data});
}
sub to_String_raw {
    my ($self) = @_;
    return JSON->new->utf8->encode($self->{config_data});
}

1;  # End of package
