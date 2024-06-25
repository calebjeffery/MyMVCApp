package MyApp::View::HomeView;

use strict;
use warnings;
use Log::Log4perl;
use MyApp::Util::Files;
# Initialize Log4perl from configuration file
Log::Log4perl->init(MyApp::Util::Files::get_relative_path('data/configuration/log4perl.conf'));
my $logger = Log::Log4perl->get_logger(__PACKAGE__);

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self;
}

sub render {
    my ($self, $data) = @_;
    $logger->info("Rendering View");
    print "Content-type: text/html\n\n";
    print <<"HTML";
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$data->{title}</title>
    <link rel="stylesheet" href="../public_html/styles.css">
</head>
<body>
    <h1>$data->{message}</h1>
</body>
</html>
HTML
}

sub render_home_page {
    my ($username) = @_;

    my $html = <<"HTML";
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Welcome</title>
    <link rel="stylesheet" href="/css/styles.css"> <!-- Link to your CSS file -->
</head>
<body>
    <div class="container">
        <h2>Welcome, $username!</h2>
        <p>This is your home page.</p>
        <p><a href="index.cgi?action=logout">Logout</a></p>
    </div>
</body>
</html>
HTML

    return $html;
}

sub render_login_form {
    return <<HTML;
<!DOCTYPE html>
<html>
<head><title>Login</title></head>
<body>
    <h2>Login</h2>
    <form method="post" action="login.cgi">
        Username: <input type="text" name="username"><br>
        Password: <input type="password" name="password"><br>
        <input type="submit" value="Login">
    </form>
</body>
</html>
HTML
}
1;
