class ShortTextAnswerPresenter < SimpleDelegator
  # @return [Hash]
  def to_param
    {
      response: response,
    }
  end
end
