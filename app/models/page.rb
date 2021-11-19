class Page < ApplicationRecord
  # Pages are definded in Contentful. If a new page is created
  # or page slug is updated, this refreshed Rails routes to refelct the change
  after_commit :refresh_routes, only: %i[create update]

private

  def refresh_routes
    return unless slug_changed?

    Rails.application.reload_routes!
  end
end
