module Support
  class CaseSavingsFormSchema < Dry::Validation::Contract
    include Concerns::TranslatableFormSchema
    config.messages.top_namespace = :case_savings_form

    params do
      optional(:savings_status).value(:symbol)
      optional(:savings_estimate_method).value(:symbol)
      optional(:savings_actual_method).value(:symbol)
      optional(:savings_estimate).maybe(:decimal)
      optional(:savings_actual).maybe(:decimal)
    end

    rule :savings_estimate do
      key.failure(:too_large) if value.to_i > 99_999_999.999
    end

    rule :savings_actual do
      key.failure(:too_large) if value.to_i > 99_999_999.999
    end
  end
end
