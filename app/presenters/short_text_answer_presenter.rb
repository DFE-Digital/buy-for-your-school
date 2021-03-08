class ShortTextAnswerPresenter < SimpleDelegator
  def to_param
    response
  end
end
