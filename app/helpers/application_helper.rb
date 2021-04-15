# frozen_string_literal: true

module ApplicationHelper
  def custom_banner_tag_class
    return "preview-tag" if ENV["CONTENTFUL_PREVIEW_APP"].eql?("true")
  end

  def banner_tag
    return I18n.t("banner.preview.tag") if ENV["CONTENTFUL_PREVIEW_APP"].eql?("true")
    I18n.t("banner.beta.tag")
  end

  def banner_message
    return I18n.t("banner.preview.message") if ENV["CONTENTFUL_PREVIEW_APP"].eql?("true")
    I18n.t("banner.beta.message", support_email: ENV.fetch("SUPPORT_EMAIL"))
  end
end
