# Collect better quality
#
class ExitSurvey::BetterQualityForm < ExitSurvey::Form
  # @!attribute [r] better quality
  # @return [Symbol]
  option :better_quality, Types::Params::Symbol, optional: true

  # @return [Array<String>] strongly_agree, agree, neither, disagree, strongly_disagree
  def better_quality_options
    @better_quality_options ||= ExitSurveyResponse.better_qualities.keys.reverse
  end
end
