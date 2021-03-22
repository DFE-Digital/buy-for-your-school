# Require environment variables on initialisation
# https://github.com/bkeepers/dotenv#required-keys
if defined?(Dotenv)
  Dotenv.require_keys(
    "CONTENTFUL_URL",
    "CONTENTFUL_SPACE",
    "CONTENTFUL_ENVIRONMENT",
    "CONTENTFUL_ACCESS_TOKEN",
    "CONTENTFUL_DEFAULT_CATEGORY_ENTRY_ID",
    "CONTENTFUL_PREVIEW_APP",
    "CONTENTFUL_ENTRY_CACHING"
  )
end
