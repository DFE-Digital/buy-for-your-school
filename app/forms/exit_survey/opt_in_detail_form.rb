# Collect opt in detail

class ExitSurvey::OptInDetailForm < ExitSurvey::Form
  # @!attribute [r] opt in name
  # @return [String]
  option :opt_in_name, optional: true

  # @!attribute [r] opt in email
  # @return [String]
  option :opt_in_email, optional: true
end