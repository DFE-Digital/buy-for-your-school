class RequestFormSchema < Schema
  config.messages.top_namespace = :request

  params do
    optional(:procurement_amount).maybe(Types::DecimalField)
    optional(:special_requirements_choice).value(:string)
    optional(:special_requirements).value(:string)
    optional(:step).value(:string)
    optional(:back).value(:bool)
  end

  rule(:procurement_amount) do
    key.failure(:invalid) if key? && value == ""
    key.failure(:too_large) if key? && value.present? && Float(value) >= 10**7
  end

  rule(:special_requirements_choice) do
    key.failure(:missing) if key? && value.blank?
  end

  rule(:special_requirements) do
    key.failure(:missing) if key? && value.blank? && values[:special_requirements_choice] == "yes"
  end
end
