# Validate opt in form
#
class ExitSurvey::OptInFormSchema < Schema
  config.messages.top_namespace = :exit_survey

  params do
    optional(:opt_in).value(:bool)
  end

  rule(:opt_in) do
    key.failure(:missing) if key? && value.blank?
  end
end
