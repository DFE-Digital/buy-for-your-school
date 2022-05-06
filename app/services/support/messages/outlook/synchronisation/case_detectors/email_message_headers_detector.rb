module Support
  module Messages
    module Outlook
      module Synchronisation
        module CaseDetectors
          class EmailMessageHeadersDetector
            def self.detect(message)
              message.case_reference_from_headers
            end
          end
        end
      end
    end
  end
end
