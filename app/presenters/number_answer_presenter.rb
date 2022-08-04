class NumberAnswerPresenter < BasePresenter
  # @return [String]
  def response
    super.to_s
  end

  # A hash of options used in Liquid templates to aid
  # content designers when implementing step logic.
  #
  # @see GetAnswersForSteps
  #
  # @return [Hash]
  def to_param
    {
      response:,
    }
  end
end
