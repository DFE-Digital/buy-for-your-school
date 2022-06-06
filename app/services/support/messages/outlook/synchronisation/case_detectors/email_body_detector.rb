module Support
  module Messages
    module Outlook
      module Synchronisation
        module CaseDetectors
          class EmailBodyDetector
            def self.detect(message)
              # please note, full stop in regex
              message.body.content.match(/Your reference number is: ([0-9]{6,6})\./).to_a.last
            end
          end
        end
      end
    end
  end
end
