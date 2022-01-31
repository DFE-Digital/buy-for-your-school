module Support
  #
  # Download and persist emails from shared inbox
  #
  class SynchronizeSharedInboxJob < ApplicationJob
    queue_as :support

    def perform
      IncomingEmails::SharedMailbox.synchronize(emails_since: 4.minutes.ago, folder: :inbox)
      IncomingEmails::SharedMailbox.synchronize(emails_since: 4.minutes.ago, folder: :sent_items)
    end
  end
end
