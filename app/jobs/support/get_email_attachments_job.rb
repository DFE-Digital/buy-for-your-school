module Support
  #
  # Pull attachment from MS graph, upload to active storage and persist metadata
  #
  class GetEmailAttachmentsJob < ApplicationJob
    queue_as :support

    def perform(message_ms_id)
      IncomingEmails::EmailAttachments.download(message_ms_id: message_ms_id)
    end
  end
end
