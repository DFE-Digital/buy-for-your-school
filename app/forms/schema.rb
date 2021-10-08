require "dry/validation"

Dry::Validation.load_extensions(:predicates_as_macros)

#
# @author Peter Hamilton
#
class Schema < Dry::Validation::Contract
  import_predicates_as_macros

  config.messages.backend = :i18n
  config.messages.top_namespace = :forms
  config.messages.load_paths << Rails.root.join("config/locales/validation/en.yml")
end
