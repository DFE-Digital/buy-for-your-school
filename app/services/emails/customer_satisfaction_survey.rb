# frozen_string_literal: true

require "notify/email"

class Emails::CustomerSatisfactionSurvey < Notify::Email
  option :template, Types::String, default: proc { Support::EmailTemplates::IDS[:customer_satisfaction_survey] }
  option :survey_id, Types::String
  option :caseworker_name, Types::String

private

  def template_params
    super.merge(**satisfaction_level_links, caseworker_name:)
  end

  def satisfaction_level_links
    links = {}
    satisfaction_levels = CustomerSatisfactionSurveyResponse.satisfaction_levels.dup
    satisfaction_levels.each_key { |k| links["#{k}_link"] = Rails.application.routes.url_helpers.edit_customer_satisfaction_surveys_satisfaction_level_url(@survey_id, customer_satisfaction_survey: { satisfaction_level: k.to_s }) }
    links.symbolize_keys
  end
end
