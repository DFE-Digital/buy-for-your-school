class CheckboxesAnswerPresenter < SimpleDelegator
  def response
    super.reject(&:blank?)
  end
end
