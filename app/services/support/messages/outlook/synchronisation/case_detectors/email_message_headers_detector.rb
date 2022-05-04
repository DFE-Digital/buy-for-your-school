module Support
  module Messages
    module Outlook
      module Synchronisation
        module CaseDetectors
          class EmailMessageHeadersDetector
            def self.detect(message)
              case_reference_header = message
                .internet_message_headers
                .find { |header| header[:name] == "GHBSCaseReference" }

              (case_reference_header || {})[:value]
            end
          end
        end
      end
    end
  end
end
