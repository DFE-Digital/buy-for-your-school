module Support
  module Messages
    module Outlook
      module Synchronisation
        module Steps
          class SurfaceEmailOnCase
            def self.call(message, email)
              send(message.inbox? ? :on_inbox : :on_outbox, message, email)
            end

            def self.on_inbox(_message, email)
              email.case.update!(action_required: true)

              interaction = email.case.interactions.email_from_school.find_or_initialize_by(
                body: "Received email from school",
                additional_data: { email_id: email.id },
              )
              interaction.save!
            end

            def self.on_outbox(_message, email)
              interaction = email.case.interactions.email_to_school.find_or_initialize_by(
                body: "Sent email to school",
                additional_data: { email_id: email.id },
              )
              interaction.save!
            end
          end
        end
      end
    end
  end
end
