require "dry/schema"

class AppSchema < Dry::Schema::Params
  define do
    # TODO: prepare locales for dry-validation of user data
    # config.messages.load_paths << '/my/app/config/locales/en.yml'
    config.messages.backend = :i18n
  end
end
