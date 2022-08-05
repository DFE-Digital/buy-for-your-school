module Support
  module Messages
    module Outlook
      class SurfaceEmailOnCase
        def self.call(email)
          event_type = "email_#{email.inbox? ? 'from' : 'to'}_school"
          email_body = email.body.presence || "- No message body -"

          email.case.interactions.create!(
            event_type:,
            body: email_body,
            additional_data: { email_id: email.id },
            created_at: email.sent_at,
          )
        end
      end
    end
  end
end
