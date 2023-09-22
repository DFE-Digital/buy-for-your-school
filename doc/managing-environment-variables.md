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

Currently in order to add a new environment variable, they will need to be added to the terraform .tfvars file for that particular environment and a manual deployment must take place.

Add the new environment variables to the variable `application_env` and then deploy the environment.
