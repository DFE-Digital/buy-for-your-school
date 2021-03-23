# Getting started

1. [Install Docker for Mac](https://docs.docker.com/docker-for-mac/install/)
1. copy `/.env.example` into `/.env.development.local`.

  Our intention is that the example should include enough to get the application started quickly. If this is not the case, please ask another developer for a copy of their `/.env.development.local` file.

1. `script/server`
1. Visit http://localhost:3000

## Running the tests

### The whole test suite

* Using Docker has high parity, you don't have to install any dependencies but it takes longer to run (~20 seconds):

    ```bash
    docker-compose -f docker-compose.test.yml run --rm test bundle exec rake
    ```
* Without Docker is faster (~5 seconds) but has lower parity and you will need to install local dependencies on your machine first:

    ```bash
    brew install postgres
    brew services start postgres
    brew install redis
    brew services start redis
    createuser postgres --super
    rbenv install 2.6.6 && rbenv local 2.6.6
    gem install bundle && bundle
    RAILS_ENV=test rake db:setup
    ```
    ```ruby
    script/test
    ```

### RSpec only

```
bundle exec rspec spec/*
```

## Starting a Rails console

```
script/console
```

## Running Brakeman

Run [Brakeman](https://brakemanscanner.org/) to highlight any security vulnerabilities:
```bash
brakeman
```

To pipe the results to a file:
```bash
brakeman -o report.text
```
