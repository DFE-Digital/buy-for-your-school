# Validate opt in form
#
class ExitSurvey::OptInFormSchema < Schema
  config.messages.top_namespace = :exit_survey

  params do
    required(:opt_in).value(:bool)
  end
end
