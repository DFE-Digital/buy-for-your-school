class SingleDateAnswerPresenter < SimpleDelegator
  def response
    I18n.l(super)
  end
end
