class RadioAnswerPresenter < SimpleDelegator
  def response
    super.capitalize
  end
end
