# :nocov:
module Support
  class CaseFilterFormSchema < Dry::Validation::Contract
    include Concerns::TranslatableFormSchema
    config.messages.top_namespace = :case_filter_form
  end
end
# :nocov:
