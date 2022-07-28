# Validate future support form
#
class ExitSurvey::FutureSupportFormSchema < Schema
  config.messages.top_namespace = :exit_survey

  params do
    required(:future_support).value(:string)
  end

  rule(:future_support) do
    key.failure(:missing) if value.blank?
  end
end
