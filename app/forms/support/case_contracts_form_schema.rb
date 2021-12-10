module Support
  class CaseContractsFormSchema < Dry::Validation::Contract
    include Concerns::TranslatableFormSchema

    params do
      optional(:supplier).maybe(:string)
      optional(:started_at).maybe(:string)
      optional(:ended_at).maybe(:string)
      optional(:spend).maybe(:decimal)
      optional(:duration).maybe(:string)
    end
  end
end
