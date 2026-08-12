# AGENTS.md

## Cursor Cloud specific instructions

This repository is a single **Perl 5 CGI MVC web app** (`MyApp`). There is no bundled
application server, database, or other external service — persistence is local JSON/session
files. Perl CPAN dependencies are declared in `cpanfile` and are installed system-wide by the
startup update script, so `perl`/`prove` find them without any `PERL5LIB` or `local::lib` setup.

### Lint / Test / Run

- **Test:** `prove -lr tests/` from the repo root (`-l` adds `lib/` to `@INC`). Tests mock
  `MyApp::Model::UserModel` and drive controllers directly, so no web server is needed.
- **Lint:** there is no configured linter; `perl -c <file>` is the only static check available.
- **Run (dev):** the app is CGI, so it must be served by a CGI-capable server. Stock Python works
  and needs no extra Perl deps:
  ```
  chmod +x cgi-bin/*.cgi
  PERL5LIB=/workspace/lib python3 -m http.server 8080 --cgi
  ```
  Then open `http://localhost:8080/cgi-bin/index.cgi`.

### Non-obvious gotchas

- **Exec bit:** `cgi-bin/*.cgi` are NOT executable in git; a CGI server needs them executable, so
  run `chmod +x cgi-bin/*.cgi` before serving (this mode change is not committed).
- **`PERL5LIB` when serving:** the `.cgi` scripts do `use lib '../lib'`, which only resolves when
  cwd is `cgi-bin/`. When serving from the repo root, export `PERL5LIB=/workspace/lib` so the
  `MyApp::*` modules load regardless of cwd.
- **Login cookie is not persisted in a browser:** on successful login the app writes a
  `CGI::Session` file to `data/sessions/` and redirects, but it never emits a `Set-Cookie`
  header. A browser therefore returns to the login form after login. To reach the authenticated
  "Welcome" home page over HTTP, send the `CGISESSID` cookie manually, matching a session file in
  `data/sessions/` whose contents include a `username` (e.g.
  `curl -b "CGISESSID=<id>" http://localhost:8080/cgi-bin/index.cgi`).
- **Credentials** are hardcoded in `lib/MyApp/Model/UserModel.pm`: `alice`/`alice123` and
  `bob`/`bob456`.
- **`cpanm --installdeps .` exits non-zero:** `cpanfile` has `requires 'perl', '5.20'`, which
  cpanm reads as the decimal `5.2` (greater than `5.038002`) and bails with a non-zero exit even
  though all module deps install. The update script installs the explicit module list instead to
  stay reliable.
- Sessions live in `data/sessions/` and logs in `logs/myapp.log` (both auto-created, git-ignored).
