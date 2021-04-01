class ShortTextAnswerPresenter < SimpleDelegator
  def to_param
    {
      response: response
    }
  end
end
