# Collect user satisfaction
#
class ExitSurvey::SatisfactionForm < ExitSurvey::Form
  # @!attribute [r] satisfaction
  # @return [Symbol]
  option :satisfaction_level, Types::Params::Symbol, optional: true

  # @return [Array<String>] very_satisfied, satisfied, neither, dissatisfied, very_dissatisfied
  def satisfaction_options
    @satisfaction_options ||= ExitSurveyResponse.satisfaction_levels.keys.reverse
  end
end
