# Require environment variables on initialisation
# https://github.com/bkeepers/dotenv#required-keys
if defined?(Dotenv)
  Dotenv.require_keys(
    "APPLICATION_URL",
    "CONTENTFUL_SPACE",
    "CONTENTFUL_ENVIRONMENT",
    "CONTENTFUL_DELIVERY_TOKEN",
    "CONTENTFUL_PREVIEW_TOKEN",
    "CONTENTFUL_ENTRY_CACHING",
    "SUPPORT_EMAIL",
    "REDIS_URL",
    "PROC_OPS_TEAM",
    "DSI_ENV",
  )
end
