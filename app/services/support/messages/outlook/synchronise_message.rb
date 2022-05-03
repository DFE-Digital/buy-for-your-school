module Support
  module Messages
    module Outlook
      class SynchroniseMessage
        def self.call(message)
          email = Support::Email.find_or_initialize_by(outlook_id: message.id)

          return unless email.new_record?

          sync_process = [
            Synchronisation::Steps::PersistEmail,
            Synchronisation::Steps::AttachEmailToCase,
            Synchronisation::Steps::PersistEmailAttachments,
            Synchronisation::Steps::SurfaceEmailOnCase
          ]

          Support::Email.transaction do
            sync_process.each do |step|
              step.call(message, email)
            end
          end
        end
      end
    end
  end
end
