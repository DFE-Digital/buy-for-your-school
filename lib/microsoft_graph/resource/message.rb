module MicrosoftGraph
  module Resource
    # https://docs.microsoft.com/en-us/graph/api/resources/message?view=graph-rest-1.0
    class Message
      extend Dry::Initializer

      option :body, Types.DryConstructor(ItemBody)
      option :body_preview, Types::String
      option :conversation_id, Types::String
      option :from, Types.DryConstructor(Recipient)
      option :has_attachments, Types::Bool
      option :id, Types::String
      option :internet_message_id, Types::String
      option :importance, Types::String
      option :is_draft, Types::Bool
      option :is_read, Types::Bool
      option :internet_message_headers, Types.Array(Types::Hash)
      option :received_date_time, Types.Instance(DateTime)
      option :sent_date_time, Types.Instance(DateTime)
      option :subject, Types::String
      option :to_recipients, Types.Array(Types.DryConstructor(Recipient))
    end
  end
end
