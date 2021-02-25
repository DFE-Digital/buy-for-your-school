class CheckboxesAnswerPresenter < SimpleDelegator
  def response
    super.reject(&:blank?).map { |answer|
      answer.tr!("_", " ")
      answer.capitalize!
    }.join(", ")
  end
end
