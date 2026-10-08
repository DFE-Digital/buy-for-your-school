module Redirectable
  extend ActiveSupport::Concern

private

  def redirect_legacy_slugs
    match = RedirectMatcher.call(request.path)
    return unless match

    redirect_to match.destination_path, status: match.status
  end
end
