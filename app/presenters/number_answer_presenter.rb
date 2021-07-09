class NumberAnswerPresenter < SimpleDelegator
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
