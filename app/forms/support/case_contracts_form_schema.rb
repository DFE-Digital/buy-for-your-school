module Support
  class CaseContractsFormSchema < Schema
    config.messages.top_namespace = :case_new_contract_form

    params do
      optional(:supplier).maybe(:string)
      optional(:started_at).maybe(:date)
      optional(:ended_at).maybe(:date)
      optional(:spend).maybe(:decimal)
      optional(:duration_in_months).maybe(:integer)
    end
  end
end
