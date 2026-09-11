class Fabs::ApplicationController < ApplicationController
  include Breadcrumbs

  rescue_from ContentfulRecordNotFoundError, with: :record_not_found

  skip_before_action :authenticate_user!
  before_action :page_back_link, :canonical_url
  before_action :reload_translations, if: -> { Rails.configuration.x.public_frontend_contentful_enabled }

private

  def record_not_found
    render "errors/not_found", status: :not_found
  end

  def page_back_link
    @page_back_link ||= root_path
  end

  def reload_translations
    unless Rails.cache.exist?(I18n::Backend::Contentful::CACHE_KEY)
      Rails.logger.info "Cache expired. Reloading translations..."
      I18n.backend.reload!
    end
  end

  def canonical_url
    @canonical_url ||= request.url
  end
end
