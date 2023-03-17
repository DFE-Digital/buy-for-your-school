#!/bin/bash
set -e

echo "ENTRYPOINT: Starting docker entrypoint..."

setup_database()
{
  echo "ENTRYPOINT: Running rake db:prepare..."
  # Migrate the database and if one doesn't exist then create one
  bundle exec rake db:prepare
  echo "ENTRYPOINT: Finished database setup."
}

if [ ! "$RAILS_ENV" == "production" ]; then
  # Bundle any Gemfile changes in development without requiring a long image rebuild
  if bundle check; then echo "ENTRYPOINT: Skipping bundle for development"; else bundle; fi

  echo "ENTRYPOINT: Compile /public/assets (if required) for development"
  cp -R /srv/node_modules $APP_HOME
  RAILS_ENV=production SECRET_KEY_BASE=key bundle exec rails assets:precompile
fi

if [ -z ${SKIP_DATABASE_SETUP} ]; then
if [ -z ${DATABASE_URL+x} ]; then echo "ENTRYPOINT: Skipping database setup"; else setup_database; fi
fi

echo "ENTRYPOINT: Finished docker entrypoint."
exec "$@"
