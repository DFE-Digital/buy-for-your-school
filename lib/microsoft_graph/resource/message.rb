module MicrosoftGraph
  module Resource
    # https://docs.microsoft.com/en-us/graph/api/resources/message?view=graph-rest-1.0
    class Message
      extend Dry::Initializer

      option :body, Types.Instance(ItemBody)
      option :body_preview, Types::String
      option :conversation_id, Types::String
      option :id, Types::String
      option :internet_message_id, Types::String
      option :importance, Types::String
      option :is_read, Types::Bool
      option :sent_date_time, Types.Instance(DateTime)
      option :subject, Types::String
      option :to_recipients, Types.Array(Types.Instance(Recipient))

      def self.from_payload(payload)
        body = ItemBody.from_payload(payload["body"])
        body_preview = payload["bodyPreview"]
        conversation_id = payload["conversationId"]
        id = payload["id"]
        internet_message_id = payload["internetMessageId"]
        importance = payload["importance"]
        is_read = payload["isRead"]
        sent_date_time = DateTime.parse(payload["sentDateTime"])
        subject = payload["subject"]
        to_recipients = payload["toRecipients"].map { |recipient| Recipient.from_payload(recipient) }

        new(
          body: body,
          body_preview: body_preview,
          conversation_id: conversation_id,
          id: id,
          internet_message_id: internet_message_id,
          importance: importance,
          is_read: is_read,
          sent_date_time: sent_date_time,
          subject: subject,
          to_recipients: to_recipients,
        )
      end
    end
  end
end
