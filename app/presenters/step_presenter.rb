class StepPresenter < SimpleDelegator
  def question?
    contentful_model == "question"
  end

  def statement?
    contentful_model == "staticContent"
  end

  def help_text_html
    return if help_text.blank?

    Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(help_text).html_safe
  end

  def status_id
    "#{id}-status"
  end

  def response
    @response ||=
      case contentful_type
      when "radios" then RadioAnswerPresenter.new(answer).response
      when "short_text" then ShortTextAnswerPresenter.new(answer).response
      when "long_text" then LongTextAnswerPresenter.new(answer).response
      when "single_date" then SingleDateAnswerPresenter.new(answer).response
      when "checkboxes" then CheckboxesAnswerPresenter.new(answer).concatenated_response
      when "number" then NumberAnswerPresenter.new(answer).response
      when "currency" then CurrencyAnswerPresenter.new(answer).response
      end
  end
end
