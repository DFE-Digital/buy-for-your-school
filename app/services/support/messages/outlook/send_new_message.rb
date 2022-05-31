module Support
  module Messages
    module Outlook
      class SendNewMessage
        def initialize(message_text:, recipient:, sender:, ms_graph_client: MicrosoftGraph.client, file_attachments: [])
          @ms_graph_client = ms_graph_client
          @message_text = message_text
          @recipient = recipient
          @sender = sender
          @file_attachments = file_attachments
        end

        def call
          draft_message = update_message_with_content(create_draft_message)
          update_message_with_file_attachments(draft_message)
          send_message(draft_message)
          SynchroniseMessage.call(draft_message)
        end

      private

        attr_reader :ms_graph_client, :message_text, :recipient, :sender, :file_attachments

        def create_draft_message
          draft_message = ms_graph_client.create_message(
            user_id: SHARED_MAILBOX_USER_ID,
            http_headers: { "Prefer" => 'IdType="ImmutableId"' },
          )

          wrap_message(draft_message)
        end

        def update_message_with_content(draft_message)
          updated_message = ms_graph_client.update_message(
            user_id: SHARED_MAILBOX_USER_ID,
            message_id: draft_message.id,
            details: {
              body: {
                "ContentType" => "HTML",
                "content" => message_body_content(draft_message),
              },
              toRecipients: [
                {
                  "emailAddress": {
                    "address": @recipient,
                  },
                },
              ],
            },
          )

          wrap_message(updated_message)
        end

        def update_message_with_file_attachments(draft_message)
          file_attachments.each do |file_attachment|
            ms_graph_client.add_file_attachment_to_message(
              user_id: SHARED_MAILBOX_USER_ID,
              message_id: draft_message.id,
              file_attachment: file_attachment,
            )
          end
        end

        def send_message(draft_message)
          ms_graph_client.send_message(
            user_id: SHARED_MAILBOX_USER_ID,
            message_id: draft_message.id,
          )
        end

        def message_body_content(draft_message)
          draft_message.body.content
        end

        def wrap_message(draft_message)
          Message.from_resource(draft_message, mail_folder: MailFolder.sent_items, ms_graph_client: ms_graph_client)
        end
      end
    end
  end
end
