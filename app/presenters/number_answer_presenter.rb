class NumberAnswerPresenter < BasePresenter
  # @return [String]
  def response
    super.to_s
  end

  # @return [Hash]
  def to_param
    {
      response: response,
    }
  end
end
