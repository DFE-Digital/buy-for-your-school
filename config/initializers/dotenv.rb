# Require environment variables on initialisation
# https://github.com/bkeepers/dotenv#required-keys
#
# If RAILS_ENV development or test
#
if defined?(Dotenv)
  Dotenv.require_keys(
    "APPLICATION_URL",
    "REDIS_URL",
    "DATABASE_URL",
    "SECRET_KEY_BASE",
    "CONTENTFUL_SPACE_ID",
    "CONTENTFUL_ENVIRONMENT",
    "CONTENTFUL_ACCESS_TOKEN",
    "CONTENTFUL_WEBHOOK_SECRET",
    "NOTIFY_API_KEY",
  )
end
