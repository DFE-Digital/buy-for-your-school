# Validate saved time form
#
class ExitSurvey::SavedTimeFormSchema < Schema
  config.messages.top_namespace = :exit_survey

  params do
    required(:saved_time).value(:string)
  end

  rule(:saved_time) do
    key.failure(:missing) if value.blank?
  end
end
