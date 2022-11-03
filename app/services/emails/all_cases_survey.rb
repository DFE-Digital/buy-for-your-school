# frozen_string_literal: true

require "notify/email"

class Emails::AllCasesSurvey < Notify::Email
  option :template, Types::String

  option :survey_id, Types::String

private

  def template_params
    super.merge(satisfaction_level_links)
  end

  def satisfaction_level_links
    links = {}
    satisfaction_levels = AllCasesSurveyResponse.satisfaction_levels.dup
    satisfaction_levels.each { |k, _v| links["#{k}_link"] = Rails.application.routes.url_helpers.edit_all_cases_survey_satisfaction_url(@survey_id, satisfaction_level: k.to_s) }
    links.symbolize_keys
  end
end
