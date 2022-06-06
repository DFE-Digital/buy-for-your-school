module Support
  module Messages
    module Outlook
      module Synchronisation
        module Steps
          class AttachEmailToCase
            def self.call(message, email)
              message_case_detection = MessageCaseDetection.new(message)

              support_case = email.case
              support_case = message_case_detection.detect_existing_or_create_new_case if support_case.nil?
              support_case = message_case_detection.new_case if support_case.closed?
              support_case.open! if support_case.resolved?

              email.update!(case: support_case)
            end
          end
        end
      end
    end
  end
end
