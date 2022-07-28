# Validate opt in detail form
#
class ExitSurvey::OptInDetailFormSchema < Schema
  config.messages.top_namespace = :exit_survey

  params do
    required(:opt_in_name).value(:string)
    required(:opt_in_email).value(:string)
  end

  rule(:opt_in_name) do
    key.failure(:missing) if value.blank?
  end

  rule(:opt_in_email) do
    key.failure(:missing) if value.blank?
  end
end
