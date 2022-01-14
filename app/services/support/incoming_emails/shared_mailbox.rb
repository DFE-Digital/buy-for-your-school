module Support
  module IncomingEmails
    class SharedMailbox
      def self.synchronize(folder:, emails_since: nil, graph_client: MicrosoftGraph.client)
        shared_mailbox = SharedMailbox.new(graph_client: graph_client, folder: folder)
        shared_mailbox.emails(since: emails_since).each do |message|
          Support::Email.import_from_mailbox(message, folder: folder)
        end
      end

      FOLDER_MAP = {
        inbox: "Inbox",
        sent_items: "SentItems",
      }.freeze

      attr_reader :graph_client, :folder

      def initialize(graph_client:, folder:)
        @graph_client = graph_client
        @folder = FOLDER_MAP.fetch(folder)
      end

      def emails(since: nil)
        graph_client.list_messages_in_folder(SHARED_MAILBOX_USER_ID, folder, query: [
          ("$filter=sentDateTime ge #{since.utc.iso8601}" if since.present?),
          "$orderby=sentDateTime asc",
        ].compact)
      end
    end
  end
end
