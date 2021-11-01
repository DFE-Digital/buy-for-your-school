# Getting started

## Setup

## 1. Running the project with Docker

Using [Docker](https://docs.docker.com/docker-for-mac/install) has high parity, you don't have to install any dependencies to run the app, as the project is run in an isolated container, but it takes longer to run. The preferred option is to run code in Docker.

### Development (Docker)

Running the server:

- Install [Node.js](https://nodejs.org/en/download/) and run `$ npm install`
- Run the utility script to start a container `$ script/server`

If there is a favicon.ico error or Docker is running and the pages do not seem to load, try running:

- `$ docker exec -it buy-for-your-school_web_1 bundle exec rails assets:precompile`

### Testing (Docker)

Convenience script for containerised equivalent `$ script/spec`.
You may specify an optional spec file to run, `$ script/spec ./spec/features/this_spec.rb`.

### Debugging (Docker)

The project uses [Pry](https://github.com/pry/pry) with [Byebug](https://github.com/deivid-rodriguez/byebug) in place of [IRB](https://guides.rubyonrails.org/command_line.html#bin-rails-console)

- Run the following script to start a container `$ script/console`

### CICD (Docker)

`script/test` is the Docker command target chaining dependency updates, migrations, testing, linting and security checks.

## 2. Running the project locally

Without [Docker](https://docs.docker.com/docker-for-mac/install) is faster but has lower parity and you will need to install local dependencies on your machine first.

### Installing Dependencies (local)

1. Install [Homebrew](https://brew.sh)
1. Copy `/Brewfile.example` to `/Brewfile` and uncomment any required dependencies
1. Run `$ brew bundle` to install any missing dependencies

- pandoc, basictex and graphviz should be installed if not currently

### Development (local)

Running the server:

- The assets need to be precompiled by running `$ rake assets:precompile`
- `$ bundle exec rails server`
- see `Procfile.dev` for starting puma with SSL

### Testing (local)

- Run test suite `$ bundle exec rspec` or `bundle exec rake spec`
- Run lint check `$ bundle exec rubocop` or `bundle exec rake rubocop`
- Run test suite and lint check `bundle exec rake`

In order to run the test suite locally, if not already, the assets will need to be precompiled (`$ rake assets:precompile`)

### Debugging (local)

The project uses [Pry](https://github.com/pry/pry) with [Byebug](https://github.com/deivid-rodriguez/byebug) in place of [IRB](https://guides.rubyonrails.org/command_line.html#bin-rails-console)

- Start a console locally `$ bundle exec rails console`

### Optional Alternative Setup (local)

ASDF can also be used to manage multiple runtime versions. Example step-by-step guide using [ASDF](https://asdf-vm.com) for dependencies.

1. Install Postgres

   ```
   $ asdf plugin add postgres
   $ POSTGRES_EXTRA_CONFIGURE_OPTIONS=--with-uuid=e2fs asdf install postgres latest
   $ pg_ctl start
   $ createuser postgres --super
   $ createdb postgres
   ```

1. Install Redis

   ```
   $ asdf plugin add redis
   $ asdf install redis latest
   $ redis-server
   ```

1. Install Node

   ```
   $ asdf plugin add nodejs
   $ asdf install nodejs latest
   ```

1. Install [Ruby](https://gds-way.cloudapps.digital/manuals/programming-languages/ruby.html#conventional-tooling) (or use alternative installers like [Rbenv](https://github.com/rbenv/rbenv), [RVM](https://github.com/rvm/rvm), [Chruby](https://github.com/postmodern/chruby))

   ```
   $ asdf plugin add ruby
   $ asdf install ruby 2.6.6
   ```

1. Install the gems

   ```
   $ gem install bundle
   $ bundle
   ```

1. Additional install configuration (if required)

   ```
   $ gem install pg -- --with-pg-config=$(asdf which pg_config)
   ```

1. Prepare the databases
   ```
   $ rake db:setup
   $ RAILS_ENV=test rake db:setup
   ```

## Environment Variables

1. Obtain environment variable secrets from another member of the development team
1. Copy `/.env.example` to `/.env.development.local`

## Scripts

Located within the /scripts folder, there are a number of utility scripts for running processes from the terminal.

1. When using Docker:

   - `$ script/server` will allow you to launch the application in a container
   - `$ script/spec` will run the test suite
   - `$ script/console` will execute a rails console

2. When running the project locally,
   - `$ script/test` can be used to run the test suite

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
