# Setting up a development environment

## Install Dependencies

The following instructions are written with Mac OS users in mind, please seek
alternative documentation for Linux or Windows users.

### Ruby

You can use either [RVM](https://rvm.io/) or [asdf](https://github.com/asdf-vm/asdf)
with the [asdf-ruby plugin](https://github.com/asdf-vm/asdf-ruby) to install
Ruby. Both will work; **asdf** has an advantage in allowing you to manage
versions of a wide range of tools (NodeJS, Python, etc.) via a single,
consistent interface.

Refer to `.ruby-version` in the root of the project for the version of Ruby
currently used.

### PostgreSQL

Any version of Postgres ≥ 11 should work without a problem.

```
$ brew install postgresql@17
```

You might need to start postgres:

```
$ brew services restart postgresql@17
```

### Redis

```
$ brew install redis
```

You might need to start redis:

```
$ brew services restart redis
```

### Chromedriver

NOTE: you will need actual Google Chrome installed.

```
$ brew install chromedriver
```

Ensure chromedriver is not blocked by system security:

```
$ xattr -d com.apple.quarantine `which chromedriver`
```

## Set environment variables

You will need the `.env.development.local` file for your development
environment. Please ask an existing member of the team for an up-to-date copy.

The database is configured via the `DATABASE_URL` environment variable. You can
set this to match your local environment in `.env.development.local` and
`.env.test.local`.

Related: [Managing environment variables](managing-environment-variables.md).

## Initialise the application

Install gems:

```
$ bundle install
```

Set up the database and seed the local environment:

```
$ bundle exec rails db:setup
$ rails self_serve:populate_categories
$ rails case_management:seed
$ rails request_for_help:seed
```

If you have valid MS Graph credentials you can also seed the local emails:

```
$ bundle exec rails case_management:seed_shared_inbox_emails
```

Precompile the assets:

```
$ bundle exec rails assets:precompile
```

## Create a self-signed SSL certificate

In order to authenticate against the DfE Sign In test environment, you must be
using HTTPS locally. To create a certificate valid for one year:

```
$ openssl req -x509 -sha256 -nodes -newkey rsa:2048 -days 365 -keyout localhost.key -out localhost.crt
```

## Start the application

To run the application and supporting processes (as defined in `Procfile.dev`),
serving over HTTPS using the certificate created earlier:

```
$ ./bin/dev
```

Navigate to [https://localhost:3000/](https://localhost:3000/)

### Run individual processes

If required, processes can be run alone by specifying them by name as
listed in `Procfile.dev`:

```
$ ./bin/dev {web|sidekiq|webpack|css}
```

## Sign in

Follow the **Start now** link from the application. This will take you to
the DfE Sign In test environment. Create an account and request access to the
**DfE Commercial Procurement Operations** organisation.

Related: [DfE Sign In](dfe-sign-in.md).

## Grant yourself roles

[Grant roles to your user](roles-and-portals.md) in order to get access to
the different portals.

## Get commit access

Ask a developer with GitHub access to add your GitHub handle as a
_Collaborator_ to allow you to create pull requests.

In order to deploy to the `development` environment you need to be allowed to
push to the `development` branch. Ask for your GitHub handle to be added
within the branch protections.
