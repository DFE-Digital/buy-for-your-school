module Support
  module Messages
    module Outlook
      module Synchronisation
        module Steps
          class AttachEmailToCase
            include Wisper::Publisher

            def call(message, email)
              message_case_detection = MessageCaseDetection.new(message)

              support_case = email.case
              support_case = message_case_detection.detect_existing_or_create_new_case if support_case.nil?
              support_case = message_case_detection.new_case if support_case.closed?

              support_case.reopen_due_to_email if support_case.resolved? && message.inbox?

              email.update!(case: support_case)

              if email.previous_changes.key?("case_id")
                broadcast(:"#{message.inbox? ? "received" : "sent"}_email_attached_to_case",
                  { support_case_id: support_case.id, support_email_id: email.id })
              end
            end

            def self.call(message, email)
              new.call(message, email)
            end
          end
        end
      end
    end
  end
end
