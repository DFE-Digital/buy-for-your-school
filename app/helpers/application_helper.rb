# frozen_string_literal: true

# ApplicationHelper provides banner and footer tags.
module ApplicationHelper
  include MarkdownHelper
  require "date"

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

  def fabs_govuk_link_to(link_text, url, **options)
    safe_url = safe_url(url)
    external_attrs = external_link_attributes(url)
    if is_external_link?(url)
      link_text = "#{h(link_text)}<span class=\"govuk-visually-hidden\"> #{h(t('shared.external_link.opens_in_new_tab'))}</span>".html_safe
    end

    govuk_link_to(link_text, safe_url, **options.merge(external_attrs))
  end

  def is_external_link?(url)
    return false unless url.is_a?(String)

    begin
      uri = URI.parse(url)
      return false unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)

      uri.host != request.host
    rescue URI::InvalidURIError
      false
    end
  end

  def external_link_attributes(url)
    is_external_link?(url) ? { target: "_blank", rel: "noopener noreferrer" } : {}
  end

  def safe_url(url)
    return "#" unless url.is_a?(String)

    uri = URI.parse(url)
    uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS) ? url : "#"
  rescue URI::InvalidURIError => e
    Rollbar.error(e, url: url)
    "#"
  end

  def usability_survey_url(url)
    base_url = "https://www.get-help-buying-for-schools.service.gov.uk/usability_surveys/new"
    safe_url = safe_url(url)
    return_url = safe_url == "#" ? request.original_url : safe_url

    params = {
      service: "find_a_buying_solution",
      return_url: UrlVerifier.generate(return_url),
    }
    "#{base_url}?#{params.to_query}"
  end

  def customer_satisfaction_survey_url(source)
    base_url = ENV["GHBS_SERVER_URL"] || ENV["APPLICATION_URL"] || ""
    return "#" if base_url.blank?

    uri = URI.join(base_url, "/customer_satisfaction_surveys/new")
    uri.query = {
      service: "find_a_buying_solution",
      source: source,
    }.to_query
    safe_url(uri.to_s)
  end

  def format_date(date_input)
    return "" if date_input.blank?

    # Handle FABS case: date_input is a String or Date/DateTime from Contentful
    if date_input.is_a?(String)
      I18n.l(Date.parse(date_input), format: :standard)
    elsif date_input.is_a?(Date) || date_input.is_a?(DateTime) || date_input.is_a?(Time)
      I18n.l(date_input.to_date, format: :standard)
    # Handle BFYS case: date_input is a Hash with :day, :month, :year
    elsif date_input.is_a?(Hash)
      date_parts = date_input.values_at(:day, :month, :year)
      return "" unless date_parts.all?(&:present?)

      day, month, year = date_parts.map(&:to_i)
      I18n.l(Date.new(year, month, day), format: :standard)
    else
      ""
    end
  rescue Date::Error, ArgumentError => e
    Rollbar.error(e, date_input: date_input) if defined?(Rollbar)
    ""
  end

  def page_title(page_title = nil)
    page_title.present? ? "#{h(page_title.strip)} - #{t('service.name')}" : t("service.name")
  end

  def service_navigation_items
    items = []
    items << { path: "/about-this-service", text: t("service.navigation.about") }
    items
  end

private

  def service_navigation_active?(path)
    request.path == path
  end

  def service_navigation_any_active?
    service_navigation_items.any? { |item| service_navigation_active?(item[:path]) }
  end
end
