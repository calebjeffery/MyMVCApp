package MyApp::View::HomeView;

use strict;
use warnings;
use HTML::Entities qw(encode_entities);
use Log::Log4perl;

my $logger = Log::Log4perl->get_logger(__PACKAGE__);

sub render_home_page {
    my ($username, $data) = @_;
    $data ||= {};

    my $safe_username = encode_entities($username // '');
    my $safe_title    = encode_entities($data->{title}    // 'Welcome');
    my $safe_message  = encode_entities($data->{message}  // '');

    $logger->info('Rendering home page');

    return <<"HTML";
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>$safe_title</title>
    <link rel="stylesheet" href="/css/styles.css">
</head>
<body>
    <div class="container">
        <h2>Welcome, $safe_username!</h2>
        <p>$safe_message</p>
        <p><a href="index.cgi?action=logout">Logout</a></p>
    </div>
</body>
</html>
HTML
}

1;
