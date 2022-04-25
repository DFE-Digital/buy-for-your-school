# frozen_string_literal: true

# ApplicationHelper provides banner and footer tags.
module ApplicationHelper
  def banner_tag
    I18n.t("banner.beta.tag")
  end

  def banner_message
    I18n.t("banner.beta.message", feedback_link: link_to(I18n.t("banner.beta.feedback_link"), "https://dferesearch.fra1.qualtrics.com/jfe/form/SV_2gE5Us8IIKxYge2", class: "govuk-link", target: "_blank", rel: :noopener))
  end

  def dsi_url(**args)
    ::Dsi::Uri.new(**args).call.to_s
  end
end
