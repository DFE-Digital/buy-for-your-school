#
# Base schema
#
class Schema < Dry::Validation::Contract
  import_predicates_as_macros

  config.messages.backend = :i18n
  config.messages.top_namespace = :forms
  config.messages.load_paths << Rails.root.join("config/locales/validation/en.yml")

  # Regex \p{Zs} (a whitespace character that is invisible, but does take up space) matches non-breaking space
  # Regex \p{Cf} (invisible formatting indicator) matches zero-length space
  # See: https://www.regular-expressions.info/unicode.html
  VALID_PHONE_NUMBER_REGEX = /\A[\d\s\-+()\p{Zs}\p{Cf}]+\z/
end
