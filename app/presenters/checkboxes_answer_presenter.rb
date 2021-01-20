class CheckboxesAnswerPresenter < SimpleDelegator
  def response
    super.reject(&:blank?).map(&:capitalize).join(", ")
  end
end
