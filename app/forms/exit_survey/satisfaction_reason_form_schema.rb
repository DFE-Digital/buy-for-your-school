# Validate user satisfaction form
#
class ExitSurvey::SatisfactionReasonFormSchema < Schema
  config.messages.top_namespace = :exit_survey

  params do
    optional(:satisfaction_text).value(:string)
  end
end
