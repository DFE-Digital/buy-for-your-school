class PagePresenter < BasePresenter
  def time_stamp
    updated_at.strftime("%e %B %Y")
  end

  def present_body
    html = <<~HTML
      <div class="govuk-grid-column-#{body_grid_size}-thirds">
        <div class="md-override">
          #{formatter(body).html_safe}
        </div>
        <p class="govuk-body-s">Last updated #{time_stamp}</p>
      </div>
    HTML

    html.html_safe
  end

  def present_sidebar
    return unless sidebar

    html = <<~HTML
      <div class="govuk-grid-column-one-third">
        #{formatter(sidebar).html_safe}
      </div>
    HTML

    html.html_safe
  end

private

  def formatter(content)
    DocumentFormatter.new(
      content: content,
      from: :markdown,
      to: :html,
    ).call
  end

  def body_grid_size
    if sidebar.present?
      "two"
    else
      "three"
    end
  end
end
