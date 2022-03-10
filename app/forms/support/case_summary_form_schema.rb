module Support
  class CaseSummaryFormSchema < Dry::Validation::Contract
    include Concerns::TranslatableFormSchema

    params do
      optional(:support_level).maybe(:string)
      optional(:value).maybe(:decimal)
    end
  end
end
