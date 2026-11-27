module Support
  class UpdateEmailSubjectJob < ApplicationJob
    queue_as :support

    def perform(email_ids:, to_case_id:, from_case_id: nil)
      Support::Case::UpdateEmailSubject.new(email_ids:, to_case_id:, from_case_id:).call
    rescue StandardError => e
      Rails.logger.error("UpdateEmailSubject failed for case=#{kase.ref} email=#{email.id}: #{e.message}")
    end
  end
end
