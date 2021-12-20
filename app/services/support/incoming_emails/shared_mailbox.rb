module Support
  module IncomingEmails
    class SharedMailbox
      attr_reader :graph_client

      def initialize(graph_client: MicrosoftGraph.client)
        @graph_client = graph_client
      end

      def synchronize(emails_since: 30.minutes.ago)
        recent_emails(emails_since).each do |message|
          support_email = Support::Email.find_or_initialize_by(
            outlook_id: message.id,
            outlook_conversation_id: message.conversation_id,
          )
          support_email.update!(
            subject: message.subject,
            is_read: message.is_read,
            is_draft: message.is_draft,
            has_attachments: message.has_attachments,
            body_preview: message.body_preview,
            body: message.body.content,
            received_at: message.received_date_time,
            sent_at: message.sent_date_time,
            sender: { address: message.from.email_address.address, name: message.from.email_address.name },
            recipients: message.to_recipients.map(&:email_address).map do |email_address|
              { address: email_address.address, name: email_address.name }
            end,
          )
        end
      end

    private

      def recent_emails(emails_since)
        graph_client.list_messages_in_folder(SHARED_MAILBOX_USER_ID, SHARED_MAILBOX_FOLDER_ID, query: [
          "$filter=sentDateTime ge #{emails_since.utc.iso8601}",
          "$orderby=sentDateTime asc",
        ])
      end
    end
  end
end
