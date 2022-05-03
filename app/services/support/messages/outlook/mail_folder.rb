module Support
  module Messages
    module Outlook
      class MailFolder
        FOLDER_INBOX      = 'Inbox'.freeze
        FOLDER_SENT_ITEMS = 'SentItems'.freeze
        FOLDER_MAP        = {
          inbox:      FOLDER_INBOX,
          sent_items: FOLDER_SENT_ITEMS
        }.freeze

        def initialize(folder:, messages_after: 15.minutes.ago, ms_graph_client: MicrosoftGraph.client)
          @folder          = FOLDER_MAP.fetch(folder)
          @messages_after  = messages_after
          @ms_graph_client = ms_graph_client
        end

        def recent_messages
          query = ["$filter=sentDateTime ge #{messages_after.utc.iso8601}", "$orderby=sentDateTime asc"]

          ms_graph_client
            .list_messages_in_folder(SHARED_MAILBOX_USER_ID, folder, query: query)
            .map {|message| Message.from_resource(message, mail_folder: self, ms_graph_client: ms_graph_client) }
        end

        def inbox?
          folder == FOLDER_INBOX
        end

        private
        attr_reader :folder, :messages_after, :ms_graph_client
      end
    end
  end
end
