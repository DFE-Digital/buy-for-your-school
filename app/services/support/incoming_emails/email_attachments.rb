# frozen_string_literal: true

module Support
  module IncomingEmails
    class EmailAttachments

      def self.download(email:, graph_client: MicrosoftGraph.client)
        email_attachments = EmailAttachments.new(graph_client: graph_client, email: email)
        email_attachments.for_message.each do |attachment|
          Support::EmailAttachment.import_attachment(attachment, email)
        end
      end

      attr_reader :graph_client, :email

      def initialize(graph_client:, email:)
        @graph_client = graph_client
        @email = email
      end

      def for_message
        graph_client.get_file_attachments(SHARED_MAILBOX_USER_ID, email.outlook_id)
      end
    end
  end
end
