# Collect user satisfaction
#
class ExitSurvey::SatisfactionReasonForm < ExitSurvey::Form
  # @!attribute [r] satisfaction_text
  # @return [String]
  option :satisfaction_text, optional: true
end
