module Support
  #
  # Download and persist emails from shared inbox
  #
  class ResyncEmailIdsJob < ApplicationJob
    queue_as :support

    include Support::Messages::Outlook

    def perform
      resync_email_ids = Support::Messages::Outlook::ResyncEmailIds.new(messages_updated_after: 15.minutes.ago)
      resync_email_ids.call
    end
  end
end
