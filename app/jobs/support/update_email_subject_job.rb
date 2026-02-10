# frozen_string_literal: true

module Support
  class UpdateEmailSubjectJob < ApplicationJob
    queue_as :support

    def perform(email_id:, case_id:)
      email = Email.find(email_id)
      kase = Support::Case.find(case_id)

      Support::Case::UpdateEmailSubject.new(email:, kase:).call
    rescue StandardError => e
      Rails.logger.error("UpdateEmailSubject failed for case=#{kase.ref} email=#{email.id}: #{e.message}")
    end
  end
end
