# Getting started

## Setup

1. Install [Homebrew](https://brew.sh)
1. Obtain [Contentful API Keys](https://app.contentful.com)
1. Copy `/.env.example` into `/.env.development.local`

Using Docker has high parity, you don't have to install any dependencies but it takes longer to run.
Without Docker is faster but has lower parity and you will need to install local dependencies on your machine first.
The preferred option is to run code locally against containerised services.

## Local Environment

1. Install [Docker](https://docs.docker.com/docker-for-mac/install) and [ASDF](https://asdf-vm.com)
    ```
    $ brew bundle
    ```
1. Install Postgres (optional)
    ```
    $ asdf plugin add postgres
    $ POSTGRES_EXTRA_CONFIGURE_OPTIONS=--with-uuid=e2fs asdf install postgres latest
    $ pg_ctl start
    $ createuser postgres --super
    $ createdb postgres
    ```
1. Install Redis (optional)
    ```
    $ asdf plugin add redis
    $ asdf install redis latest
    $ redis-server
    ```
1. Install Node (optional)
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


## Development

- Start server locally `$ bundle exec rails server`
- Utility script for containerised equivalent `$ script/server`

## Debugging

The project uses [Pry](https://github.com/pry/pry) with [Byebug](https://github.com/deivid-rodriguez/byebug) in place of [IRB](https://guides.rubyonrails.org/command_line.html#bin-rails-console)

- Start console locally `$ bundle exec rails console`
- Utility script for containerised equivalent `$ script/console`

## Testing

- Run test suite `$ bundle exec rspec`
- Run test suite and lint check `bundle exec rake`
- [deprecated] utility `$ script/test` (rbenv/bundle/migrations/rspec/standardrb/brakeman)

Running in the test docker environment can be achieved by prefixing the previous commands with:
```bash
$ docker-compose -f docker-compose.test.yml run --rm test
```

## Security

Run [Brakeman](https://brakemanscanner.org/) to highlight any security vulnerabilities:
```
$ brakeman
```

To pipe the results to a file:
```
$ brakeman -o report.text
```
