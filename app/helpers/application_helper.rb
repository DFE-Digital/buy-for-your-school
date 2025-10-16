# frozen_string_literal: true

# ApplicationHelper provides banner and footer tags.
module ApplicationHelper
  def banner_tag
    I18n.t("banner.beta.tag")
  end

  def banner_message
    I18n.t(
      "banner.beta.message",
      feedback_link: link_to(
        "#{I18n.t('banner.beta.feedback_link')}<span class=\"govuk-visually-hidden\"> opens in new tab</span>".html_safe,
        banner_feedback_link,
        class: "govuk-link",
        target: "_blank",
        rel: :noopener,
      ),
    )
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
    on_cec_index = current_page?(cec_onboarding_cases_path) || current_page?("/cec")

    on_cases_index || on_frameworks || on_eando_index || on_cec_index
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
    elsif request.path.starts_with?("/energy")
      :energy_for_schools
    else
      :create_a_spec
    end
  end

  def register_your_interest_form_url
    "https://submit.forms.service.gov.uk/form/8895/multi-academy-trusts-register-your-interest-in-energy-for-schools/1049539"
  end
end
