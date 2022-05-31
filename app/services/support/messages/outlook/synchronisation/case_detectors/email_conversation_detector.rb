module Support
  module Messages
    module Outlook
      module Synchronisation
        module CaseDetectors
          class EmailConversationDetector
            def self.detect(message)
              support_case = Support::Email
                .where(outlook_conversation_id: message.conversation_id)
                .where.not(case_id: nil)
                .order("sent_at ASC")
                .first
                .try(:case)

              support_case.try(:ref)
            end
          end
        end
      end
    end
  end
end
