# Getting started

Using [Docker](https://docs.docker.com/docker-for-mac/install) has high parity,
you don't have to install any dependencies to run the app, as the project is run
in an isolated container, but it takes longer to run.

The preferred option is to work with Docker (option 1).

## Environment Variables

- Obtain environment variable secrets from another member of the development team
- Copy `/.env.example` to `/.env.development.local` and populate

## Utility Scripts

Within `/scripts`, there are a number of convenience scripts for running processes in containers.

---

## 1. Using Docker

`$ script/build` will build and tag the container images used in docker compose.

### Development

`$ script/server` will launch the rails development server

    NB: run script/build if the image ghbs:dev does not exist locally
    -----------------------------------------------------------------
    [+] Running 8/8
    ⠿ Network ghbs_default
    ⠿ Network ghbs_ghbs
    ⠿ Volume "ghbs_db_dev"
    ⠿ Volume "ghbs_cache_dev"
    ⠿ Container ghbs_db
    ⠿ Container ghbs_cache
    ⠿ Container ghbs_worker
    ⠿ Container ghbs_dev

The project uses [Pry](https://github.com/pry/pry) with [Byebug](https://github.com/deivid-rodriguez/byebug)
in place of [IRB](https://guides.rubyonrails.org/command_line.html#bin-rails-console)

`$ script/console` will enter a rails console

### Test

`$ script/spec` will run the whole test suite, but can accept an optional spec path, which it will output in documentation format.


### CICD

Please note that in the pipeline the script `script/test` is run, which is responsible
for chaining together dependency updates, migrations, testing, linting and security checks.

---

## 2. Without Docker (local installation)

### Dependencies

**OSX**

- Install [Homebrew](https://brew.sh)
- Copy `/Brewfile.example` to `/Brewfile` and uncomment any required dependencies like `pandoc`, `basictex` and `graphviz`
- Run `$ brew bundle` to install any missing dependencies

### Development

- The assets need to be pre-compiled by running `$ rake assets:precompile`
- Run the server using `$ bundle exec rails server` if you are bypassing DfE Sign In,
otherwise [click here](dfe-sign-in.md) for more information.
- Start the console `$ bundle exec rails console`

### Test

- Run test suite `$ bundle exec rspec` or `bundle exec rake spec`
- Run lint check `$ bundle exec rubocop` or `bundle exec rake rubocop`
- Run test suite and lint check `bundle exec rake`

### Services

ASDF can also be used to manage multiple runtime versions. Example step-by-step guide using [ASDF](https://asdf-vm.com) for dependencies.

Postgres

```
$ asdf plugin add postgres
$ POSTGRES_EXTRA_CONFIGURE_OPTIONS=--with-uuid=e2fs asdf install postgres latest
$ pg_ctl start
$ createuser postgres --super
$ createdb postgres
```

Redis

```
$ asdf plugin add redis
$ asdf install redis latest
$ redis-server
```

Node

```
$ asdf plugin add nodejs
$ asdf install nodejs latest
```

[Ruby](https://gds-way.cloudapps.digital/manuals/programming-languages/ruby.html#conventional-tooling) - alternative package managers like [Rbenv](https://github.com/rbenv/rbenv), [RVM](https://github.com/rvm/rvm), [Chruby](https://github.com/postmodern/chruby) can also be used

```
$ asdf plugin add ruby
$ asdf install ruby <VERSION>
```

Rubygems

```
$ gem install bundle
$ bundle
```

Additional install configuration (if required)

```
$ gem install pg -- --with-pg-config=$(asdf which pg_config)
```

Prepare the databases

```
$ rake db:prepare
$ RAILS_ENV=test rake db:prepare
```

## Annotations

`rails notes` are used to provide WIP information for developers.

## Security

Run [Brakeman](https://brakemanscanner.org/) to highlight any security vulnerabilities:

```
$ brakeman
```

To pipe the results to a file:

```
$ brakeman -o report.text
```
