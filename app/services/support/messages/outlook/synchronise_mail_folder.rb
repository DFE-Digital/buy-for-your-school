module Support
  module Messages
    module Outlook
      class SynchroniseMailFolder
        def self.call(mail_folder)
          mail_folder.recent_messages.each do |message|
            SynchroniseMessage.call(message)
          end
        end
      end
    end
  end
end
