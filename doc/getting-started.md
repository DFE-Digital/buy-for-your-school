# Getting started

## Setup

Using [Docker](https://docs.docker.com/docker-for-mac/install) has high parity, you don't have to install any dependencies but it takes longer to run.
Without [Docker](https://docs.docker.com/docker-for-mac/install) is faster but has lower parity and you will need to install local dependencies on your machine first.

The preferred option is to run code in Docker.

1. Install [Homebrew](https://brew.sh)
1. Copy and edit `/Brewfile.example` to `/Brewfile` if needed.
1. Run `$ brew bundle` to install any missing dependencies
1. Obtain environment variable secrets from another member of the development team
1. Copy and edit `/.env.example` to `/.env.development.local`

## Development

Running the server:

- `$ bundle exec rails server`
- see `Procfile.dev` for starting puma with SSL
- Or use the utility script for a containerised equivalent `$ script/server`


## Debugging

The project uses [Pry](https://github.com/pry/pry) with [Byebug](https://github.com/deivid-rodriguez/byebug) in place of [IRB](https://guides.rubyonrails.org/command_line.html#bin-rails-console)

- Start a console locally `$ bundle exec rails console`
- Convenience script for containerised equivalent `$ script/console`

## Annotations

`rails notes` are used to provide WIP information for developers.

## Testing

- Run test suite `$ bundle exec rspec` or `bundle exec rake spec`
- Run lint check `$ bundle exec rubocop` or `bundle exec rake rubocop`
- Run test suite and lint check `bundle exec rake`

Convenience script for containerised equivalent `$ script/spec`.
You may specify an optional spec file to run, `$ script/spec ./spec/features/this_spec.rb`.

## CICD

`script/test` is the Docker command target chaining dependency updates, migrations, testing, linting and security checks.


## Security

Run [Brakeman](https://brakemanscanner.org/) to highlight any security vulnerabilities:
```
$ brakeman
```

To pipe the results to a file:
```
$ brakeman -o report.text
```


### Optional Setup

Example step-by-step guide using [ASDF](https://asdf-vm.com) for dependencies.

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
