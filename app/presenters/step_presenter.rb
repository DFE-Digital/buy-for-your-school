class StepPresenter < SimpleDelegator
  def question?
    contentful_model == "question"
  end

  def help_text_html
    return unless help_text.present?
    Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(help_text).html_safe
  end
end
