# Getting started

Take the following steps to getting started:

- [Setup your development environment](getting-started/development-environment.md)
- [Getting your DfE Sign In Accounts](dfe-sign-in.md)
- [Getting commit access to the repo](#getting-commit-access)
- [Starting the application](#starting-the-application)
- [Grant yourself roles](roles-and-portals.md)
- [Seed your local environment](#seed-your-local-environment)


## Getting Commit Access

Ask a developer with github access to add your github handle as a "Collaborator", this will allow you to create pull requests.

In order to deploy to the `development` environment you need to be allowed to push to the `development` branch, so ask for your github handle to be added within the branch protections.

## Starting the application

To start up the application with all processes (See Procfile.dev):

```
$ ./bin/dev
```

To start up the application only (no sidekiq or asset compilation):

```
$ bundle exec rails server -b 'ssl://0.0.0.0:3000?key=localhost.key&cert=localhost.crt'
```

### Manually starting asset watching and compilation

NOTE: `./bin/dev` will do this for you automatically.

To watch and compile javascript:

```
$ yarn build --watch
```

To watch and compile css:

```
$ yarn build:css --watch
```

## Seed your local environment

Run the following seeds:

```
$ rails self_serve:populate_categories
$ rails case_management:seed
$ rails request_for_help:seed
```

If you have valid MS Graph credentials you can also seed the local emails:

```
$ rails case_management:seed_shared_inbox_emails
```
