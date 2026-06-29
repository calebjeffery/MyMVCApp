package MultiApp::View::TaskView;

use strict;
use warnings;
use HTML::Entities qw(encode_entities);

sub render_task_dashboard {
    my (%args) = @_;
    my $username    = encode_entities( $args{username} // '' );
    my $tasks       = $args{tasks} // [];
    my $data_source = encode_entities( $args{data_source} // 'sqlite' );
    my $error       = $args{error} ? encode_entities( $args{error} ) : '';

    my $source_selector = _render_source_selector($data_source);
    my $task_rows       = _render_task_rows($tasks);
    my $error_html      = $error ? qq(<p class="error">$error</p>) : '';

    return <<"HTML";
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Task Dashboard - Multi-DAO App</title>
    <link rel="stylesheet" href="/css/styles.css">
</head>
<body>
    <div class="container wide">
        <header class="dashboard-header">
            <h2>Task Dashboard</h2>
            <p>Welcome, $username! <a href="index.cgi?action=logout">Logout</a></p>
        </header>

        $error_html

        <section class="source-panel">
            <h3>Data Source</h3>
            $source_selector
            <p class="hint">Current source: <span class="badge">$data_source</span></p>
        </section>

        <section class="task-panel">
            <h3>Tasks</h3>
            <form method="post" action="index.cgi" class="task-form">
                <input type="hidden" name="action" value="task_create">
                <input type="text" name="title" placeholder="New task title" required>
                <input type="submit" value="Add Task">
            </form>

            <table class="task-table">
                <thead>
                    <tr>
                        <th>Title</th>
                        <th>Status</th>
                        <th>Source</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    $task_rows
                </tbody>
            </table>
        </section>
    </div>
</body>
</html>
HTML
}

sub _render_source_selector {
    my ($current) = @_;
    my @sources = qw(sqlite mariadb api aggregate);

    my $options = join '',
      map {
        my $selected = $_ eq $current ? ' selected' : '';
        my $label    = encode_entities($_);
        qq(<option value="$label"$selected>$label</option>);
      } @sources;

    return <<"HTML";
<form method="post" action="index.cgi" class="source-form">
    <input type="hidden" name="action" value="set_source">
    <select name="source">$options</select>
    <input type="submit" value="Switch Source">
</form>
HTML
}

sub _render_task_rows {
    my ($tasks) = @_;
    return qq(<tr><td colspan="4">No tasks found.</td></tr>) unless @$tasks;

    return join '', map { _render_task_row($_) } @$tasks;
}

sub _render_task_row {
    my ($task) = @_;
    my $id        = encode_entities( $task->{id} // '' );
    my $title     = encode_entities( $task->{title} // '' );
    my $source    = encode_entities( $task->{source} // '' );
    my $completed = $task->{completed} ? 1 : 0;
    my $status    = $completed ? 'Done' : 'Open';
    my $toggle_label = $completed ? 'Mark Open' : 'Mark Done';

    return <<"HTML";
<tr>
    <td>$title</td>
    <td>$status</td>
    <td><span class="badge badge-$source">$source</span></td>
    <td class="actions">
        <form method="post" action="index.cgi" class="inline-form">
            <input type="hidden" name="action" value="task_toggle">
            <input type="hidden" name="id" value="$id">
            <input type="hidden" name="source" value="$source">
            <input type="hidden" name="completed" value="$completed">
            <input type="submit" value="$toggle_label">
        </form>
        <form method="post" action="index.cgi" class="inline-form">
            <input type="hidden" name="action" value="task_delete">
            <input type="hidden" name="id" value="$id">
            <input type="hidden" name="source" value="$source">
            <input type="submit" value="Delete">
        </form>
    </td>
</tr>
HTML
}

1;
