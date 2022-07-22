# Validate hear about service form
#
class ExitSurvey::HearAboutServiceFormSchema < Schema
  config.messages.top_namespace = :exit_survey

  params do
    optional(:hear_about_service).value(:string)
    optional(:hear_about_service_other).value(:string)
  end

  rule(:hear_about_service) do
    key.failure(:missing) if value.blank?
  end

  rule(:hear_about_service_other) do
    key.failure(:missing) if values[:hear_about_service] == "other" && value.blank?
  end
end
