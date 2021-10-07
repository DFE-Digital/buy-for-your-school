class LongTextAnswerPresenter < SimpleDelegator
  # @return [Hash]
  def to_param
    {
      response: response,
    }
  end
end
