module Support
  class CaseSummaryFormSchema < Dry::Validation::Contract
    include Concerns::TranslatableFormSchema
    config.messages.top_namespace = :case_summary_form

    params do
      optional(:support_level).maybe(:string)
      optional(:value).maybe(:decimal)
    end
  end
end
