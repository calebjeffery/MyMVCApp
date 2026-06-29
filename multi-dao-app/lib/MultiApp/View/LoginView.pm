package MultiApp::View::LoginView;

use strict;
use warnings;

sub render_login_form {
    return <<'HTML';
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Login - Multi-DAO App</title>
    <link rel="stylesheet" href="/css/styles.css">
</head>
<body>
    <div class="container">
        <h2>Login</h2>
        <form method="post" action="index.cgi">
            <input type="hidden" name="action" value="login">
            <label>Username: <input type="text" name="username"></label><br>
            <label>Password: <input type="password" name="password"></label><br>
            <input type="submit" value="Login">
        </form>
    </div>
</body>
</html>
HTML
}

sub render_login_failed {
    return <<'HTML';
<p class="error"><strong>Login failed.</strong> Please check your username and password and try again.</p>
HTML
}

1;
