class PagePresenter < BasePresenter
  # @return [String]
  def updated_at
    I18n.t("page.updated_at", date: super)
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
    "govuk-grid-row" if sidebar
  end

  # @return [String, NilClass]
  def body_class
    "govuk-grid-column-two-thirds" if sidebar
  end
end
