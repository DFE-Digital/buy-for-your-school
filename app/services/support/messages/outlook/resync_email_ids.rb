module Support
  module Messages
    module Outlook
      class ResyncEmailIds
        # This class is used to backfill data as well as keep recent data in sync

        def initialize(messages_updated_after: 15.minutes, ms_graph_client: MicrosoftGraph.client)
          @messages_updated_after = messages_updated_after
          @ms_graph_client = ms_graph_client
        end

        def call
          recently_updated_messages.each do |message|
            email = find_local_email(message)

            next unless local_email_should_be_updated?(email, message)

            email.update!(
              outlook_internet_message_id: message["internetMessageId"],
              outlook_id: message["id"],
              outlook_conversation_id: message["conversationId"],
              in_reply_to_id: in_reply_to_id(message),
            )
          end
        end

      private

        attr_reader :messages_updated_after, :ms_graph_client

        def find_local_email(message)
          Support::Email.find_by(outlook_internet_message_id: message["internetMessageId"]) || \
            Support::Email.find_by(subject: message["subject"], sent_at: message["sentDateTime"]) # fallback to subject and sent time pair
        end

        def local_email_should_be_updated?(email, message)
          # no email to update!
          return false if email.nil?

          outlook_id_needs_updating = email.outlook_id != message["id"]
          return true if outlook_id_needs_updating

          outlook_internet_message_id_needs_setting = email.outlook_internet_message_id.nil?
          return true if outlook_internet_message_id_needs_setting

          outlook_conversation_id_needs_setting = email.outlook_conversation_id.nil?
          return true if outlook_conversation_id_needs_setting

          email.in_reply_to_id.nil? && in_reply_to_id(message).present?
        end

        def in_reply_to_id(message)
          found_value = Array(message["singleValueExtendedProperties"])
            .find { |svep| svep["id"] == MicrosoftGraph::Resource::SingleValueExtendedProperty::ID_PR_IN_REPLY_TO_ID }
          found_value.present? ? found_value["value"] : nil
        end

        def recently_updated_messages
          @recently_updated_messages ||= ms_graph_client.list_messages(SHARED_MAILBOX_USER_ID, query: [
            "$filter=lastModifiedDateTime ge #{messages_updated_after.utc.iso8601}",
            "$select=internetMessageId,subject,sentDateTime,conversationId",
            "$orderby=lastModifiedDateTime asc",
            "$expand=singleValueExtendedProperties($filter=id eq '#{MicrosoftGraph::Resource::SingleValueExtendedProperty::ID_PR_IN_REPLY_TO_ID}')",
          ])
        end
      end
    end
  end
end
