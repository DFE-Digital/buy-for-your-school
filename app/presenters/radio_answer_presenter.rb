class RadioAnswerPresenter < SimpleDelegator
  def response
    return super.capitalize if further_information.blank?

    "#{super.capitalize} - #{further_information}"
  end
end
