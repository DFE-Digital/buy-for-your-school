module Support
  class CaseSavingsFormSchema < Dry::Validation::Contract
    include Concerns::TranslatableFormSchema

    params do
      optional(:savings_status).value(:symbol)
      optional(:savings_estimate_method).value(:symbol)
      optional(:savings_actual_method).value(:symbol)
      optional(:savings_estimate).value(:decimal)
      optional(:savings_actual).value(:decimal)
    end
  end
end
