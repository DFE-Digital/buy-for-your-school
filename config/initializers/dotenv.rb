# Require environment variables on initialisation
# https://github.com/bkeepers/dotenv#required-keys
if defined?(Dotenv)
  Dotenv.require_keys("CONTENTFUL_SPACE", "CONTENTFUL_ACCESS_TOKEN")
end
