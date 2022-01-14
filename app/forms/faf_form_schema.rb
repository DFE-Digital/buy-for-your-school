#
# Validate "find-a-framework support requests"
#
class FafFormSchema < Dry::Validation::Contract
  import_predicates_as_macros

  config.messages.backend = :i18n
  config.messages.top_namespace = :forms
  config.messages.load_paths << Rails.root.join("config/locales/validation/en.yml")

  params do
    optional(:dsi).value(:bool)
  end

  rule(:dsi) do
    key.failure(:missing) unless key?
  end
end
