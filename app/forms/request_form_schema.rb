class RequestFormSchema < Schema
  config.messages.top_namespace = :request

  params do
    optional(:procurement_choice).value(:string)
    optional(:procurement_amount).value(:string)
    optional(:confidence_level).value(:string)
    optional(:special_requirements_choice).value(:string)
    optional(:special_requirements).value(:string)
    optional(:about_procurement).maybe(:bool)
    optional(:step).value(:string)
    optional(:back).value(:bool)
  end

  rule(:procurement_choice) do
    key.failure(:missing) if key? && value.blank? && values[:step] == "6"
  end

  rule(:procurement_amount) do
    key.failure(:missing) if key? && value.blank? && values[:procurement_choice] == "yes"
  end

  rule(:confidence_level) do
    key.failure(:missing) if key? && value.blank? && values[:step] == "7" && !values[:back]
  end

  rule(:special_requirements_choice) do
    key.failure(:missing) if key? && value.blank?
  end

  rule(:special_requirements) do
    key.failure(:missing) if key? && value.blank? && values[:special_requirements_choice] == "yes"
  end
end
