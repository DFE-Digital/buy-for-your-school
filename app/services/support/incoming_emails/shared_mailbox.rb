module Support
  module IncomingEmails
    class SharedMailbox
      def self.synchronize(emails_since: nil, graph_client: MicrosoftGraph.client)
        shared_mailbox = SharedMailbox.new(graph_client: graph_client)
        shared_mailbox.emails(since: emails_since).each do |message|
          Support::Email.from_message(message)
        end
      end

      attr_reader :graph_client

      def initialize(graph_client:)
        @graph_client = graph_client
      end

      def emails(since: nil)
        graph_client.list_messages_in_folder(SHARED_MAILBOX_USER_ID, SHARED_MAILBOX_FOLDER_ID, query: [
          ("$filter=sentDateTime ge #{since.utc.iso8601}" if since.present?),
          "$orderby=sentDateTime asc",
        ].compact)
      end
    end
  end
end
