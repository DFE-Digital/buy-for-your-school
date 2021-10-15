class LongTextAnswerPresenter < BasePresenter
  # @return [Hash]
  def to_param
    {
      response: response,
    }
  end
end
