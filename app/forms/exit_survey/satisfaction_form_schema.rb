# Validate user satisfaction form
#
class ExitSurvey::SatisfactionFormSchema < Schema
  config.messages.top_namespace = :exit_survey

  params do
    optional(:satisfaction_level).value(:string)
  end

  rule(:satisfaction_level) do
    key.failure(:missing) if value.blank?
  end
end
