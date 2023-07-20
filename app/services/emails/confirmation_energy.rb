# frozen_string_literal: true

require "notify/email"

# @see https://www.notifications.service.gov.uk/services/73c59fe6-a823-49b9-888b-f3960c33b11c/templates/2a2b7b46-2034-4e7b-aaec-4c9bf0b76f3f
#
class Emails::ConfirmationEnergy < Notify::Email
  option :template, Types::String, default: proc { Support::EmailTemplates::IDS[:confirmation_energy] }
end
