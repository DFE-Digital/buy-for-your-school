# frozen_string_literal: true

require "notify/email"

class Emails::AllCasesSurvey < Notify::Email
  # @see https://www.notifications.service.gov.uk/services/&ltUUID&gt/templates
  # @!attribute [r] template
  #   @return [String] Template by UUID
  option :template, Types::String

  # @!attribute [r] survey_id
  #   @return [String] ID of the exit survey to be filled out
  option :survey_id, Types::String

  def call; end

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
