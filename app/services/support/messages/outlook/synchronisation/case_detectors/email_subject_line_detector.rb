module Support
  module Messages
    module Outlook
      module Synchronisation
        module CaseDetectors
          class EmailSubjectLineDetector
            def self.detect(message)
              message.subject.match(/([0-9]{6,6})/).to_a.last
            end
          end
        end
      end
    end
  end
end
