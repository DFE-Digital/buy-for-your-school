# frozen_string_literal: true

require "notify/email"

module Support
  class Emails::ToSchool < Notify::Email
    def call
      super

      log_potential_first_contact
    end

  private

    def log_potential_first_contact
      if recipient.interactions.email_to_school.count == 1
        Support::RecordAction.new(
          case_id: recipient.id,
          action: "first_contact",
        ).call
      end
    end
  end
end
