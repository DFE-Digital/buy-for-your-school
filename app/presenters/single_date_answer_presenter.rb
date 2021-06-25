class SingleDateAnswerPresenter < SimpleDelegator
  def response
    I18n.l(super)
  end

  def to_param
    {
      response: response,
    }
  end
end
