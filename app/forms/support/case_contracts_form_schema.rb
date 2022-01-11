module Support
  class CaseContractsFormSchema < Schema
    validate_date_fields %i[started_at ended_at]

    config.messages.top_namespace = :case_contracts_form

    params do
      optional(:supplier).maybe(:string)
      optional(:started_at).maybe(:hash)
      optional(:ended_at).maybe(:hash)
      optional(:spend).maybe(:decimal)
      optional(:duration).maybe(:integer)
    end
  end
end
