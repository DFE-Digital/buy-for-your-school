module Support
  module Messages
    module Outlook
      module Synchronisation
        class MessageCaseDetection
          attr_reader :message

          def initialize(message)
            @message = message
          end

          def detect_existing_or_create_new_case
            existing_case || new_case
          end

          def new_case
            first_name, *last_name = message.sender[:name].split(" ")
            last_name              = Array(last_name).join(" ")

            Support::CreateCase.new(
              source: :incoming_email,
              email: message.sender[:address],
              first_name: first_name,
              last_name: last_name,
            ).call
          end

          def existing_case
            Support::Case.find_by(ref: detected_case_reference) if detected_case_reference.present?
          end

          def detected_case_reference
            return @detected_case_reference if @detected_case_reference.present?

            detectors = [
              CaseDetectors::EmailBodyDetector,
              CaseDetectors::EmailSubjectLineDetector,
              CaseDetectors::EmailConversationDetector,
            ]

            @detected_case_reference = detectors.lazy
              .map { |detector| detector.detect(message) }
              .find(&:present?)
          end
        end
      end
    end
  end
end
