# Collect opt in
#
class ExitSurvey::OptInForm < ExitSurvey::Form
  # @!attribute [r] opt in
  # @return [Boolean]
  option :opt_in, Types::ConfirmationField, optional: true
end
