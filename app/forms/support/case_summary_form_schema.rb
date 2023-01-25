module Support
  class CaseSummaryFormSchema < Dry::Validation::Contract
    include Concerns::TranslatableFormSchema
    config.messages.top_namespace = :case_summary_form

    params do
      optional(:source).maybe(:string)
      optional(:support_level).maybe(:string)
      optional(:value).maybe(:decimal)
    end

    rule(:source) do
      key(:source).failure(:missing) if value.blank?
    end
  end
end
