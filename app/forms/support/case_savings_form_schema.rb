module Support
  class CaseSavingsFormSchema < Dry::Validation::Contract
    include Concerns::TranslatableFormSchema

    params do
      optional(:savings_status).value(:symbol)
      optional(:savings_estimate_method).value(:symbol)
      optional(:savings_actual_method).value(:symbol)
      optional(:savings_estimate).maybe(:decimal)
      optional(:savings_actual).maybe(:decimal)
    end
  end
end
