# Setting up your development environment

- [Install Dependencies](#install-dependencies)
- [Setup environment variables](#setup-environment-variables)

## Install Dependencies

The following instructions are written with Mac OS users in mind, please seek alternative documentation for Linux or Windows users.

### Install Ruby

Follow the instructions here: https://rvm.io/

Or alternativly use the [asdf-ruby](https://github.com/asdf-vm/asdf-ruby) plugin for [asdf](https://github.com/asdf-vm/asdf)

### Install Postgres

```
$ brew install postgresql@11
```

You might need to start postgres running, use the following command whenever your postgres server is not running:

```
$ brew services restart postgresql@11
```

### Install Redis

```
$ brew install redis
```

You might need to start redis running, use the following command whenever your redis server is not running:

```
$ brew services restart redis
```

### Install Chromedriver

NOTE: you will need actual Google Chrome installed also.

```
$ brew install chromedriver
```

Ensure chromedriver is not blocked by the system when running:

```
$ xattr -d com.apple.quarantine `which chromedriver`
```

## Setup Environment Variables

You require the `.env.development.local` file for your development environment to run, please ask an existing member of the team for an up to date copy.

The database is configured via the `DATABASE_URL` environment variable. You can
set this to match your local environment in `.env.development.local` and
`.env.test.local`.

## Create a self signed SSL certificate

```
$ openssl req -x509 -sha256 -nodes -newkey rsa:2048 -days 365 -keyout localhost.key -out localhost.crt
```

## Project Setup

```
$ bundle install
$ bundle exec rails db:setup
$ bundle exec rails assets:precompile
```
