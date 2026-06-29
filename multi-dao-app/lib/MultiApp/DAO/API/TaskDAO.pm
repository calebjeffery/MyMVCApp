package MultiApp::DAO::API::TaskDAO;

use strict;
use warnings;
use base 'MultiApp::DAO::TaskDAOBase';
use HTTP::Tiny;
use JSON::MaybeXS qw(decode_json encode_json);
use Log::Log4perl;

my $logger = Log::Log4perl->get_logger(__PACKAGE__);

sub new {
    my ( $class, %args ) = @_;

    my $base_url = $args{base_url} // 'https://jsonplaceholder.typicode.com';
    $base_url =~ s{/\z}{};

    my $self = bless {
        base_url => $base_url,
        resource => $args{resource} // 'todos',
        timeout  => $args{timeout}  // 10,
        source   => 'api',
        http     => $args{http} // HTTP::Tiny->new( timeout => $args{timeout} // 10 ),
    }, $class;

    return $self;
}

sub _resource_url {
    my ($self) = @_;
    return "$self->{base_url}/$self->{resource}";
}

sub _request {
    my ( $self, $method, $path, $body ) = @_;
    $path //= '';

    my $url = $path eq '' ? $self->_resource_url() : $self->_resource_url() . "/$path";
    my %options;
    $options{content} = encode_json($body) if defined $body;
    $options{headers} = { 'Content-Type' => 'application/json' } if defined $body;

    my $response = $self->{http}->request( $method, $url, \%options );

    if ( !$response->{success} ) {
        $logger->error("API request failed: $method $url - $response->{status} $response->{reason}");
        return undef;
    }

    return $response->{content} ? decode_json( $response->{content} ) : {};
}

sub _map_todo {
    my ( $self, $todo ) = @_;
    return $self->_with_source(
        {
            id        => $todo->{id},
            title     => $todo->{title},
            completed => $todo->{completed},
        },
        $self->{source}
    );
}

sub find_all {
    my ($self) = @_;
    my $data = $self->_request('GET');
    return [] unless $data && ref $data eq 'ARRAY';

    return [ map { $self->_map_todo($_) } @$data ];
}

sub find_by_id {
    my ( $self, $id ) = @_;
    my $data = $self->_request( 'GET', $id );
    return undef unless $data && ref $data eq 'HASH' && exists $data->{id};

    return $self->_map_todo($data);
}

sub create {
    my ( $self, $task ) = @_;
    my $data = $self->_normalize_input($task);
    my $result = $self->_request( 'POST', '', $data );
    return undef unless $result && ref $result eq 'HASH';

    return $self->_map_todo($result);
}

sub update {
    my ( $self, $id, $task ) = @_;
    my $data = $self->_normalize_input($task);
    my $result = $self->_request( 'PUT', $id, $data );
    return undef unless $result && ref $result eq 'HASH';

    return $self->_map_todo($result);
}

sub delete {
    my ( $self, $id ) = @_;
    my $result = $self->_request( 'DELETE', $id );
    return defined $result ? 1 : 0;
}

1;
