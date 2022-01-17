# frozen_string_literal: true

module Support
  module IncomingEmails
    class EmailAttachments

      def self.download(message_ms_id:, graph_client: MicrosoftGraph.client)
        email_attachments = EmailAttachments.new(graph_client: graph_client, message_ms_id: message_ms_id)
        email_attachments.for_message.each do |attachment|
          Support::EmailAttachment.import_attachment(attachment, message_ms_id)
        end
      end

      attr_reader :graph_client, :message_ms_id

      def initialize(graph_client:, message_ms_id:)
        @graph_client = graph_client
        @message_ms_id = message_ms_id
      end

      def for_message
        graph_client.get_attachment(SHARED_MAILBOX_USER_ID, message_ms_id)
      end
    end
  end
end
