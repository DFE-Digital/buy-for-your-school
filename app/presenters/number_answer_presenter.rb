class NumberAnswerPresenter < SimpleDelegator
  def to_param
    response
  end
end
