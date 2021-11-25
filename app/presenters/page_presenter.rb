class PagePresenter < BasePresenter
  def updated_at
    text = I18n.t("page.updated_at")
    date_format = I18n.t("page.date_format")
    date = __getobj__.updated_at.strftime(date_format)

    "#{text} #{date}"
  end

  # @return [String]
  def body
    format(super).html_safe
  end

  # @return [String, NilClass]
  def sidebar
    return unless super

    format(super).html_safe
  end

  # @return [String, NilClass]
  def container_class
    return "govuk-grid-row" if sidebar
  end

  # @return [String, NilClass]
  def body_class
    return "govuk-grid-column-two-thirds" if sidebar
  end
end
