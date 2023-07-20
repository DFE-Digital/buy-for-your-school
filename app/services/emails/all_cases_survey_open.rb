# frozen_string_literal: true

require "notify/email"

# @see https://www.notifications.service.gov.uk/services/73c59fe6-a823-49b9-888b-f3960c33b11c/templates/76f6f7ba-26d1-4c00-addd-12dc9d8d49fc
#
class Emails::AllCasesSurveyOpen < Emails::AllCasesSurvey
  option :template, Types::String, default: proc { Support::EmailTemplates::IDS[:all_cases_survey_open] }

  option :survey_id, Types::String
end
