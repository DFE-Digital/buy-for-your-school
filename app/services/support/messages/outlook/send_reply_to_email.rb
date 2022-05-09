module Support
  module Messages
    module Outlook
      class SendReplyToEmail
        def initialize(reply_to_email:, reply_text:, sender:, ms_graph_client: MicrosoftGraph.client)
          @ms_graph_client = ms_graph_client
          @reply_to_email = reply_to_email
          @reply_text = reply_text
          @sender = sender
        end

        def call
          draft_reply = update_message_with_content(create_draft_reply)
          send_message(draft_reply)

          email = Support::Email.find_or_initialize_by(outlook_internet_message_id: draft_reply.internet_message_id)
          email.case = reply_to_email.case
          email.replying_to = reply_to_email
          email.sender = { name: sender.full_name, address: sender.email }
          email.save!

          Synchronisation::Steps::PersistEmail.call(draft_reply, email)
          Synchronisation::Steps::SurfaceEmailOnCase.call(draft_reply, email)
        end

      private

        attr_reader :ms_graph_client, :reply_to_email, :reply_text, :sender

        def create_draft_reply
          draft_reply = ms_graph_client.create_reply_message(
            user_id: SHARED_MAILBOX_USER_ID,
            reply_to_id: reply_to_email.outlook_id,
            http_headers: { "Prefer" => 'IdType="ImmutableId"' },
          )

          Reply::DraftMessage.new(draft_reply)
        end

        def update_message_with_content(draft_reply)
          updated_message = ms_graph_client.update_message(
            user_id: SHARED_MAILBOX_USER_ID,
            message_id: draft_reply.id,
            details: {
              body: {
                "ContentType" => "HTML",
                "content" => reply_body_content(draft_reply),
              },
            },
          )

          Reply::DraftMessage.new(updated_message)
        end

        def send_message(draft_reply)
          ms_graph_client.send_message(
            user_id: SHARED_MAILBOX_USER_ID,
            message_id: draft_reply.id,
          )
        end

        def reply_body_content(draft_reply)
          # reply_text    # - for a more concise reply, although from reply 3 it gets messy again
          "<html><body>#{reply_text}</body></html>#{draft_reply.body.content}"
        end
      end
    end
  end
end
