module Support
  module Messages
    module Outlook
      class SendNewMessage
        def initialize(message_text:, recipient:, subject:, sender:, ms_graph_client: MicrosoftGraph.client, file_attachments: [])
          @ms_graph_client = ms_graph_client
          @message_text = message_text
          @recipient = recipient
          @subject = subject
          @sender = sender
          @file_attachments = file_attachments
        end

        def call
          draft_message = update_message_with_content(create_draft_message)
          update_message_with_file_attachments(draft_message)
          send_message(draft_message)
          full_message = get_full_message_details(draft_message)
          SynchroniseMessage.call(full_message)
        end

      private

        attr_reader :ms_graph_client, :message_text, :recipient, :sender, :file_attachments

        def create_draft_message
          ms_graph_client.create_message(
            user_id: SHARED_MAILBOX_USER_ID,
            http_headers: { "Prefer" => 'IdType="ImmutableId"' },
          )
        end

        def update_message_with_content(draft_message_id)
          updated_message = ms_graph_client.update_message(
            user_id: SHARED_MAILBOX_USER_ID,
            message_id: draft_message_id,
            details: {
              body: {
                "ContentType" => "HTML",
                "content" => @message_text,
              },
              from: {
                "emailAddress": {
                  "name" => SHARED_MAILBOX_NAME,
                  "address" => SHARED_MAILBOX_ADDRESS,
                },
              },
              toRecipients: [
                {
                  "emailAddress": {
                    "address": @recipient,
                  },
                },
              ],
              subject: @subject,
            },
          )

          wrap_message(updated_message)
        end

        def update_message_with_file_attachments(draft_message)
          file_attachments.each do |file_attachment|
            ms_graph_client.add_file_attachment_to_message(
              user_id: SHARED_MAILBOX_USER_ID,
              message_id: draft_message.id,
              file_attachment:,
            )
          end
        end

        def send_message(draft_message)
          ms_graph_client.send_message(
            user_id: SHARED_MAILBOX_USER_ID,
            message_id: draft_message.id,
          )
        end

        def get_full_message_details(draft_reply)
          response = ms_graph_client.get_message(
            user_id: SHARED_MAILBOX_USER_ID,
            message_id: draft_reply.id,
          )
          wrap_message(response)
        end

        def message_body_content(draft_message)
          draft_message.body.content
        end

        def wrap_message(draft_message)
          Message.from_resource(draft_message, mail_folder: MailFolder.sent_items, ms_graph_client:)
        end
      end
    end
  end
end
