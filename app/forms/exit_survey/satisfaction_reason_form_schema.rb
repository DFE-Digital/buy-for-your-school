# Validate user satisfaction form
#
class ExitSurvey::SatisfactionReasonFormSchema < Schema
  config.messages.top_namespace = :exit_survey

  params do
    required(:satisfaction_text).value(:string)
  end

  rule(:satisfaction_text) do
    key.failure(:missing) if value.blank?
  end
end
