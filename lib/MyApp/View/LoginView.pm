package MyApp::View::LoginView;

use strict;
use warnings;

sub render_login_form {
    return <<'HTML';
<!DOCTYPE html>
<html>
<head><title>Login</title></head>
<body>
    <h2>Login</h2>
    <form method="post" action="index.cgi">
        <input type="hidden" name="action" value="login">
        Username: <input type="text" name="username"><br>
        Password: <input type="password" name="password"><br>
        <input type="submit" value="Login">
    </form>
</body>
</html>
HTML
}

sub render_login_failed {
    return <<'HTML';
<p><strong>Login failed.</strong> Please check your username and password and try again.</p>
HTML
}

1;
