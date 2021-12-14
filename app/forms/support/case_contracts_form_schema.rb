module Support
  class CaseContractsFormSchema < Dry::Validation::Contract
    include Concerns::TranslatableFormSchema

    params do
      optional(:supplier).maybe(:string)
      optional(:started_at).maybe(:date)
      optional(:ended_at).maybe(:date)
      optional(:spend).maybe(:decimal)
      optional(:duration_in_months).maybe(:integer)
    end
  end
end
