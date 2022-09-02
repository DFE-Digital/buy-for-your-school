module Support
  module Messages
    module Outlook
      module Synchronisation
        module Steps
          class SurfaceEmailOnCase
            def self.call(message, email)
              email.case.update!(action_required: true) if message.inbox?
            end
          end
        end
      end
    end
  end
end
