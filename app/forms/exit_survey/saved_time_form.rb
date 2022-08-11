# Collect saved time
#
class ExitSurvey::SavedTimeForm < ExitSurvey::Form
  # @!attribute [r] saved time
  # @return [Symbol]
  option :saved_time, Types::Params::Symbol, optional: true

  # @return [Array<String>] strongly_agree, agree, neither, disagree, strongly_disagree
  def saved_time_options
    @saved_time_options ||= ExitSurveyResponse.saved_times.keys.reverse
  end
end
