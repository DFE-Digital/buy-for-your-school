module Support
  module Messages
    module Outlook
      class SynchroniseMessage
        def self.call(message)
          email = Support::Email.find_or_initialize_by(outlook_internet_message_id: message.internet_message_id)

          sync_process = sync_process_for(email)

          Support::Email.transaction do
            sync_process.each do |step|
              step.call(message, email)
            end
          end
        end

        def self.sync_process_for(email)
          if email.new_record?
            # Emails imported for the first time must follow all the steps
            [
              Synchronisation::Steps::PersistEmail,
              Synchronisation::Steps::AttachEmailToCase,
              Synchronisation::Steps::PersistEmailAttachments,
            ]
          else
            # Allow existing emails to update certain fields
            Array(Synchronisation::Steps::PersistEmail)
          end
        end
      end
    end
  end
end
