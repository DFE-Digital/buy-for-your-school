module Support
  module Messages
    module Outlook
      module Synchronisation
        # Change Message interface to match Email
        class MessageEmailAdapter
          def initialize(message, email)
            @message = message
            @email = email
          end

          def id
            @email.id
          end

          def inbox?
            @message.inbox?
          end

          def body
            @message.body.content
          end

          def sent_at
            @message.sent_date_time
          end

          def case
            @email.case
          end
        end
      end
    end
  end
end
