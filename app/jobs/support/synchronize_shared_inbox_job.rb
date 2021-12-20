module Support
  #
  # Download and persist emails from shared inbox
  #
  class SynchronizeSharedInboxJob < ApplicationJob
    queue_as :support

    def perform
      shared_mailbox = IncomingEmails::SharedMailbox.new
      shared_mailbox.synchronize(emails_since: 15.minutes.ago)

      Rollbar.info "Shared inbox emails have been synchronized"
    end
  end
end
  