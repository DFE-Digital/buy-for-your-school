module Support
  module Messages
    module Outlook
      class ResyncEmailIds
        def initialize(messages_updated_after: 15.minutes, ms_graph_client: MicrosoftGraph.client)
          @messages_updated_after = messages_updated_after
          @ms_graph_client = ms_graph_client
        end

        def call
          recently_updated_messages.each do |message|
            found_email = find_local_email(message)

            if local_email_should_be_updated?(found_email, message)
              found_email.update!(outlook_internet_message_id: message["internetMessageId"], outlook_id: message["id"])
            end
          end
        end

      private

        attr_reader :messages_updated_after, :ms_graph_client

        def find_local_email(message)
          Support::Email.find_by(outlook_internet_message_id: message["internetMessageId"]) || \
            Support::Email.find_by(subject: message["subject"], sent_at: message["sentDateTime"])  # fallback to subject and sent time pair
        end

        def local_email_should_be_updated?(email, message)
          email.present? && (email.outlook_id != message["id"] || email.outlook_internet_message_id.nil?)
        end

        def recently_updated_messages
          @recently_updated_messages ||= ms_graph_client.list_messages(SHARED_MAILBOX_USER_ID, query: [
            "$filter=lastModifiedDateTime ge #{messages_updated_after.utc.iso8601}",
            "$select=internetMessageId,subject,sentDateTime",
            "$orderby=lastModifiedDateTime asc",
          ])
        end
      end
    end
  end
end
