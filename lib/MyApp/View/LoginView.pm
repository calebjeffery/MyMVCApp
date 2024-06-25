package MyApp::View::LoginView;

use strict;
use warnings;

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
