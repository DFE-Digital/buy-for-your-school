# frozen_string_literal: true

require "i18n/backend/chain"
require Rails.root.join("app/models/contentful_client")
require Rails.root.join("lib/i18n/backend/ghbs_contentful")

# Ensure we retain the default Simple backend (and therefore gem-provided locale
# files such as Faker's) while layering on top the Contentful-driven keys that
# were introduced with the FABS import.
if !I18n.backend.is_a?(I18n::Backend::Chain) && Rails.configuration.x.public_frontend_contentful_enabled
  namespaces = Rails.configuration.x.public_frontend_translation_namespaces
  contentful_backend = I18n::Backend::GhbsContentful.new(namespaces:)
  fallback_backend = I18n.backend

  I18n.backend = I18n::Backend::Chain.new(contentful_backend, fallback_backend)
end
