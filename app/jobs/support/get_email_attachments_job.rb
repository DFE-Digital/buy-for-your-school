module Support
  #
  # Pull attachment from MS graph, upload to active storage and persist metadata
  #
  class GetEmailAttachmentsJob < ApplicationJob
    queue_as :support

    def perform(email_id)
      IncomingEmails::EmailAttachments.download(email: get_email(email_id))
    end

    private

    def get_email(email_id)
      Support::Email.find(email_id)
    end
  end
end
