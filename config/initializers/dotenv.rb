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
    "CONTENTFUL_SPACE",
    "CONTENTFUL_ENVIRONMENT",
    "CONTENTFUL_DELIVERY_TOKEN",
    "CONTENTFUL_PREVIEW_TOKEN",
    "CONTENTFUL_WEBHOOK_API_KEY",
    "CONTENTFUL_SPACE_ID",
    "CONTENTFUL_ACCESS_TOKEN",
    "NOTIFY_API_KEY",
  )
end
