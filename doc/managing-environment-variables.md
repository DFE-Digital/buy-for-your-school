# Managing environment variables

## Locally

We use [Dotenv](https://github.com/bkeepers/dotenv) to manage our environment variables locally.

The repository will include safe defaults for development in `/.env.example` and for test in `/.env.test`. We use 'example' instead of 'development' (from the Dotenv docs) to be consistent with current dxw conventions and to make it more explicit that these values are not to be committed.

To manage sensitive environment variables:

1. Add the new key and safe default value to the `/.env.example` file eg. `ROLLBAR_TOKEN=ROLLBAR_TOKEN`
2. Add the new key and real value to your local `/.env.development.local` file, which should never be checked into Git. This file will look something like `ROLLBAR_TOKEN=123456789`

If the environment variable is critical whereby it is required to start the application:

- Add it to [the Dotenv initialiser](../config/initializers/_dotenv.rb).
- Add it to the Dockerfile where `rake assets:precompile` is run.

## Live environments

We use [GitHub Secrets as the canonical source of our environment variables](https://github.com/DFE-Digital/buy-for-your-school/settings/secrets/actions).

Environment variables are all managed in the same way. Secrets are kept secret by taking advantage of the protection GitHub Secrets offers. Configuration options which don't necessarily need to be kept secret are still managed through environment variables as part of being [a 12 factor app](https://12factor.net/config).

### Adding a variable

#### Application

A variable will usually be required to be added into each environment through [a new repository secret](https://github.com/DFE-Digital/buy-for-your-school/settings/secrets/actions/new). For this we use prefixes in our environment variable names:

```
APP_ENV_PROD_
APP_ENV_STAGING_
APP_ENV_RESEARCH_
```

For instance if the app needed to access `ENV["RAILS_ENV"]` in production we would add this as the key:

```
APP_ENV_PROD_RAILS_ENV
```

**Important!**
To propagate these new environment variables to the live environments we must finally deploy them manually. [Find the most recent passing deploy](https://github.com/DFE-Digital/buy-for-your-school/actions/workflows/deploy.yml) for the environment you want to provision the new variable on, view it and select "re-run jobs".

### Infrastructure

We can also make variables available for Terraform so that it can be configured.

Here's an example of how `_TF_VAR` is used together with environment prefixes to pass `SYSLOG_DRAIN_URL` information. In this case it configures where logs should be forwarded to at the infrastructure level:

```
PREVIEW_TF_VAR_SYSLOG_DRAIN_URL
```

## Viewing a variable

There is no way to view variables through GitHub Secrets once set.

Though the GitHub secret API could be used, the easiest way to get application variables is to [access the console for the environment you want](console-access.md) and ask Rails for it over the console.

```
$irb> ENV["RAILS_ENV"]
```

## Checking parity with `bin/climate`

Given there are multiple remote enviroments (staging, preview, research and production at time of writing), it's possible for some variables to be missing in some of them.

`bin/climate` provides a few helpful methods for checking things like this:

### `bin/climate` output

```console
$ bin/climate
Commands:
  climate envs            # Lists environments with a link to edit
  climate exists          # Given a ENV key, will check which environments have it defined
  climate help [COMMAND]  # Describe available commands or one specific command
  climate parity          # Lists Keys that are missing for each environment
```

### `bin/climate envs` output

```console
$ bin/climate envs
staging: https://github.com/DFE-Digital/buy-for-your-school/settings/environments/241534224/edit
preview: https://github.com/DFE-Digital/buy-for-your-school/settings/environments/241534180/edit
research: https://github.com/DFE-Digital/buy-for-your-school/settings/environments/241530720/edit
production: https://github.com/DFE-Digital/buy-for-your-school/settings/environments/241530368/edit
```

### `bin/climate parity` output

```console
$ bin/climate parity
# Missing keys:

## Staging
https://github.com/DFE-Digital/buy-for-your-school/settings/environments/241534224/edit
APP_ENV_STAGING_DFE_SIGN_IN_API_ENDPOINT
APP_ENV_STAGING_DFE_SIGN_IN_API_SECRET
APP_ENV_STAGING_GOOGLE_ANALYTICS

## Preview
https://github.com/DFE-Digital/buy-for-your-school/settings/environments/241534180/edit
APP_ENV_PREVIEW_CONTENTFUL_ENTRY_CACHING_TTL
APP_ENV_PREVIEW_CONTENTFUL_URL
APP_ENV_PREVIEW_DAYS_A_JOURNEY_CAN_BE_INACTIVE_FOR
APP_ENV_PREVIEW_GOOGLE_ANALYTICS

## Research
https://github.com/DFE-Digital/buy-for-your-school/settings/environments/241530720/edit
APP_ENV_RESEARCH_DAYS_A_JOURNEY_CAN_BE_INACTIVE_FOR
APP_ENV_RESEARCH_DOMAIN
APP_ENV_RESEARCH_RACK_ENV
APP_ENV_RESEARCH_GOOGLE_ANALYTICS

## Production
https://github.com/DFE-Digital/buy-for-your-school/settings/environments/241530368/edit
APP_ENV_PROD_DAYS_A_JOURNEY_CAN_BE_INACTIVE_FOR
```

### `bin/climate exists` output

```console
$ bin/climate exists CONTENTFUL_SPACE
Staging: not present
Preview: not present
Research: not present
Production has APP_ENV_PROD_GOOGLE_ANALYTICS
```
