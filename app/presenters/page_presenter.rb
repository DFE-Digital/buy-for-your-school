class PagePresenter < BasePresenter
  def body
    format(super).html_safe
  end

  def present_sidebar
    return unless sidebar

    html = <<~HTML
      <div class="govuk-grid-column-one-third">
        #{format(sidebar).html_safe}
      </div>
    HTML

    html.html_safe
  end

  def sidebar
    return unless super

    format(super).html_safe
  end

  def container_class
    return "govuk-grid-row" if sidebar
  end

  def body_class
    return "govuk-grid-column-two-thirds" if sidebar
  end
end

