#
# Validate "find-a-framework support requests"
#
class FafFormSchema < Dry::Validation::Contract
  import_predicates_as_macros

  config.messages.backend = :i18n
  config.messages.top_namespace = :forms
  config.messages.load_paths << Rails.root.join("config/locales/validation/en.yml")

  params do
    required(:dsi).value(:bool)  # step 1
  end

  rule(:dsi) do
    key(:dsi).failure(:missing) if [true, false].exclude?(value)
  end
end
