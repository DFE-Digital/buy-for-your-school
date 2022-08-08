module Support
  module Messages
    module Outlook
      class SurfaceEmailOnCase
        def self.call(email)
          event_type = "email_#{email.inbox? ? 'from' : 'to'}_school"

          email.case.interactions.create!(
            event_type:,
            body: "Email Interaction",
            additional_data: { email_id: email.id },
            created_at: email.sent_at,
          )
        end
      end
    end
  end
end
