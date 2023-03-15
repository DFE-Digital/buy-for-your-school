module Support
  module Messages
    module Outlook
      class SendReplyToEmail
        def initialize(reply_to_email:, reply_text:, sender:, ms_graph_client: MicrosoftGraph.client, file_attachments: [])
          @ms_graph_client = ms_graph_client
          @reply_to_email = reply_to_email
          @reply_text = reply_text
          @sender = sender
          @file_attachments = file_attachments
        end

        def call
          draft_reply = update_message_with_content(create_draft_reply)
          update_message_with_file_attachments(draft_reply)
          send_message(draft_reply)
          full_message = get_full_message_details(draft_reply)
          SynchroniseMessage.call(full_message)
        end

      private

        attr_reader :ms_graph_client, :reply_to_email, :reply_text, :sender, :file_attachments

        def create_draft_reply
          draft_reply = ms_graph_client.create_reply_all_message(
            user_id: SHARED_MAILBOX_USER_ID,
            reply_to_id: reply_to_email.outlook_id,
            http_headers: { "Prefer" => 'IdType="ImmutableId"' },
          )

          wrap_message(draft_reply)
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

          wrap_message(updated_message)
        end

        def update_message_with_file_attachments(draft_reply)
          file_attachments.each do |file_attachment|
            ms_graph_client.add_file_attachment_to_message(
              user_id: SHARED_MAILBOX_USER_ID,
              message_id: draft_reply.id,
              file_attachment:,
            )
          end
        end

        def send_message(draft_reply)
          ms_graph_client.send_message(
            user_id: SHARED_MAILBOX_USER_ID,
            message_id: draft_reply.id,
          )
        end

        def get_full_message_details(draft_reply)
          response = ms_graph_client.get_message(
            user_id: SHARED_MAILBOX_USER_ID,
            message_id: draft_reply.id,
          )
          wrap_message(response)
        end

        def reply_body_content(draft_reply)
          # reply_text    # - for a more concise reply, although from reply 3 it gets messy again
          "<html><body>#{reply_text}</body></html>#{draft_reply.body.content}"
        end

        def wrap_message(draft_reply)
          Message.from_resource(draft_reply, mail_folder: MailFolder.sent_items, ms_graph_client:)
        end
      end
    end
  end
end
