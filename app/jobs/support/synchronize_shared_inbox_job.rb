module Support
  #
  # Download and persist emails from shared inbox
  #
  class SynchronizeSharedInboxJob < ApplicationJob
    queue_as :support

    include Support::Messages::Outlook

    def perform
      SynchroniseMailFolder.call(MailFolder.new(messages_after: 15.minutes.ago, folder: :inbox))
      SynchroniseMailFolder.call(MailFolder.new(messages_after: 15.minutes.ago, folder: :sent_items))
    end
  end
end
