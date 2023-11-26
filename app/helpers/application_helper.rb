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

  def container_width_class
    enable_wide_container? ? "wide-container" : ""
  end

  def enable_wide_container?
    on_cases_index = current_page?(support_cases_path) || current_page?("/support")
    on_frameworks = request.path.starts_with?("/frameworks")
    on_eando_index = current_page?(engagement_cases_path) || current_page?("/engagement")

    (on_cases_index && Flipper.enabled?(:cms_panel_view)) || on_frameworks || on_eando_index
  end
end
