# frozen_string_literal: true

# ApplicationHelper provides banner and footer tags.
module ApplicationHelper
  def banner_tag
    I18n.t("banner.beta.tag")
  end

  def banner_message
    I18n.t("banner.beta.message", feedback_link: link_to(I18n.t("banner.beta.feedback_link"), banner_feedback_link, class: "govuk-link", target: "_blank", rel: :noopener))
  end

  def dsi_url(**args)
    ::Dsi::Uri.new(**args).call.to_s
  end

  def banner_feedback_link
    new_customer_satisfaction_survey_path(source: :banner_link, service: identify_service_for_feedback)
  end

  def sidebar_feedback_link
    new_customer_satisfaction_survey_path(source: :sidebar_link, service: identify_service_for_feedback)
  end

  def identify_service_for_feedback
    if request.path.starts_with?("/support", "/engagement", "/frameworks")
      :supported_journey
    elsif request.path.starts_with?("/procurement-support")
      :request_for_help_form
    else
      :create_a_spec
    end
  end
end
