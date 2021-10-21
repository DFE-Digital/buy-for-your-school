module Support
  module Concerns
    module TranslatableFormSchema
      extend ActiveSupport::Concern

      included do
        import_predicates_as_macros

        config.messages.backend = :i18n
        config.messages.top_namespace = :supported_forms
        config.messages.load_paths << Rails.root.join("config/locales/validation/en.yml")
      end
    end
  end
end
