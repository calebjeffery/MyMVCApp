# Multi-DAO App

A Perl CGI MVC application that manages tasks through a unified DAO interface with pluggable backends:

- **SQLite** — local file database
- **MariaDB** — relational database server
- **API** — external REST API ([JSONPlaceholder todos](https://jsonplaceholder.typicode.com/todos))
- **Aggregate** — merged view across all available backends

Based on the [MyMVCApp](../) template.

## Requirements

- Perl 5.20+
- CPAN dependencies (see `cpanfile`)

Install dependencies:

```bash
cd multi-dao-app
cpanm --installdeps .
```

## Configuration

Edit [`data/configuration/config.json`](data/configuration/config.json):

```json
{
    "data_source": "sqlite",
    "databases": {
        "sqlite": { "file": "data/sqlite/app.db" },
        "mariadb": {
            "dsn": "dbi:mysql:database=multiapp;host=127.0.0.1",
            "user": "multiapp",
            "password": "changeme"
        }
    },
    "api": {
        "base_url": "https://jsonplaceholder.typicode.com",
        "resource": "todos",
        "timeout": 10
    }
}
```

Set `data_source` to `sqlite`, `mariadb`, `api`, or `aggregate`. You can also switch sources from the task dashboard after login.

## Running the App

Point your web server at `cgi-bin/index.cgi` with `lib/` on `@INC`, or run from the project root:

```bash
cd multi-dao-app/cgi-bin
perl index.cgi
```

Serve `public_html/` as static files for CSS.

### Demo Users

| Username | Password |
|----------|----------|
| alice    | alice123 |
| bob      | bob456   |

## Running Tests

```bash
cd multi-dao-app
prove -r tests/
```

MariaDB integration tests are skipped unless you set:

```bash
export MULTIAPP_MARIADB_DSN='dbi:mysql:database=multiapp;host=127.0.0.1'
export MULTIAPP_MARIADB_USER=multiapp
export MULTIAPP_MARIADB_PASSWORD=changeme
prove tests/DAO/MariaDB/01_task_dao.t
```

## Architecture

```
cgi-bin/index.cgi
  └── HomeController (auth, routing)
        └── TaskController (CRUD)
              └── TaskModel
                    └── DAO::Factory
                          ├── SQLite::TaskDAO
                          ├── MariaDB::TaskDAO
                          ├── API::TaskDAO
                          └── Aggregate::TaskDAO
```

Each DAO implements: `find_all`, `find_by_id`, `create`, `update`, `delete`.

Tasks are represented as `{ id, title, completed, source }`.

## Optional MariaDB Setup

```sql
CREATE DATABASE multiapp;
CREATE USER 'multiapp'@'localhost' IDENTIFIED BY 'changeme';
GRANT ALL PRIVILEGES ON multiapp.* TO 'multiapp'@'localhost';
FLUSH PRIVILEGES;
```

The schema is applied automatically on first connection via [`sql/mariadb/schema.sql`](sql/mariadb/schema.sql).
