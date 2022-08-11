# Collect future support
#
class ExitSurvey::FutureSupportForm < ExitSurvey::Form
  # @!attribute [r] future support
  # @return [Symbol]
  option :future_support, Types::Params::Symbol, optional: true

  # @return [Array<String>] strongly_agree, agree, neither, disagree, strongly_disagree
  def future_support_options
    @future_support_options ||= ExitSurveyResponse.future_supports.keys.reverse
  end
end
