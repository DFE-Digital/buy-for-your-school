module Support
  module Messages
    module Outlook
      module Synchronisation
        module Steps
          class SurfaceEmailOnCase
            def self.call(message, email)
              support_case = email.case

              support_case.update!(action_required: true)

              ::Support::Messages::Outlook::SurfaceEmailOnCase.call(MessageEmailAdapter.new(message, email))
            end
          end
        end
      end
    end
  end
end
