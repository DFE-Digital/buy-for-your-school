# frozen_string_literal: true

# ApplicationHelper provides banner and footer tags.
module ApplicationHelper
  def banner_tag
    I18n.t("banner.beta.tag")
  end

  def banner_message
    I18n.t("banner.beta.message", feedback_link: link_to(I18n.t("banner.beta.feedback_link"), new_feedback_path, class: "govuk-link"))
  end

  def dsi_url(**args)
    ::Dsi::Uri.new(**args).call.to_s
  end
end
