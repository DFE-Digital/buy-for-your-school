# Validate better quality form
#
class ExitSurvey::BetterQualityFormSchema < Schema
  config.messages.top_namespace = :exit_survey

  params do
    optional(:better_quality).value(:string)
  end

  rule(:better_quality) do
    key.failure(:missing) if value.blank?
  end
end
