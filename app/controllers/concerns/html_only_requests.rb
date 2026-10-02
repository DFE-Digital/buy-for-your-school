module HtmlOnlyRequests
  extend ActiveSupport::Concern

  included do
    prepend_before_action :ensure_html_request
  end

private

  def ensure_html_request
    if request.format == Mime::ALL
      request.format = :html
      return
    end

    raise ActionController::UnknownFormat unless request.format.html?
  end
end
