module Support
  class Schema < Dry::Validation::Contract
    import_predicates_as_macros

    config.messages.backend = :i18n
    config.messages.top_namespace = :forms
    config.messages.load_paths << Rails.root.join("config/locales/validation/support/en.yml")
  end
end
