# frozen_string_literal: true

require "notify/email"

# @see https://www.notifications.service.gov.uk/services/73c59fe6-a823-49b9-888b-f3960c33b11c/templates/a56e5c50-78d1-4b5f-a2ff-73df78b7ad99
#
class Emails::AllCasesSurveyResolved < Emails::AllCasesSurvey
  option :template, Types::String, default: proc { Support::EmailTemplates::IDS[:all_cases_survey_resolved] }

  option :survey_id, Types::String
end
