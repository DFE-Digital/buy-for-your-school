class NumberAnswerPresenter < SimpleDelegator
  def response
    super.to_s
  end
  
  def to_param
    response
  end
end
