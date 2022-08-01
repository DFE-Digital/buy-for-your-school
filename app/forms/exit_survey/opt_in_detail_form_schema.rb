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
    if value.blank?
      key.failure(:missing)
    else
      key.failure(:invalid) unless URI::MailTo::EMAIL_REGEXP.match?(value)
    end
  end
end
