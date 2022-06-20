# frozen_string_literal: true

require "notify/email"

# @see https://www.notifications.service.gov.uk/services/73c59fe6-a823-49b9-888b-f3960c33b11c/templates/134bc268-2c6b-4b74-b6f4-4a58e22d6c8b
#   subject: Case ((reference)) Tell us how the Get help buying for schools service worked for you
#   Dear ((first name)),
#   Would you be willing to give us some feedback on your experience of using the Get help buying for schools service?
#   It’ll give you a chance to shape the service in the future and it’ll help us improve it for other schools.
#   This survey will help us understand how well the service has supported you. It will take 5 minutes to complete.
#   https://dferesearch.fra1.qualtrics.com/jfe/form/SV_4T5BGrOBE2pUpYG
#
# @example "Exit survey" template
#
#   Emails::ExitSurvey.new(
#     recipient: @user,
#     reference: "use case ref here",
#   ).call
#
class Emails::ExitSurvey < Notify::Email
  # @see https://www.notifications.service.gov.uk/services/&ltUUID&gt/templates
  # @!attribute [r] template
  #   @return [String] Template by UUID
  option :template, Types::String, default: proc { Support::EmailTemplates::IDS[:exit_survey] }

  # @!attribute [r] school_name
  #   @return [String] Name of the school associated to the case
  option :school_name, Types::String

  def self.generate_survey_query_string(case_ref, school_name, email)
    populated_responses = {
      "case_ref": case_ref,
      "school_name": school_name,
      "email": email,
    }

    "?Q_EED=#{Base64.strict_encode64(populated_responses.to_json)}"
  end

  def call
    Rollbar.info("Sending exit survey email")

    super
  end

private

  def template_params
    super.merge(survey_query_string: self.class.generate_survey_query_string(reference, school_name, recipient.email))
  end
end
