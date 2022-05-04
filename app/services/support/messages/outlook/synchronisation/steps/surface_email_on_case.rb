module Support
  module Messages
    module Outlook
      module Synchronisation
        module Steps
          class SurfaceEmailOnCase
            def self.call(message, email)
              support_case = email.case

              support_case.update!(action_required: true)

              event_type = "email_#{message.inbox? ? 'from' : 'to'}_school"
              email_body = message.body.content.presence || "- No message body -"

              support_case.interactions.create!(
                event_type: event_type,
                body: email_body,
                additional_data: { email_id: email.id },
                created_at: message.sent_date_time,
              )
            end
          end
        end
      end
    end
  end
end
