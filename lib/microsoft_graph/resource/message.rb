module MicrosoftGraph
  module Resource
    # https://docs.microsoft.com/en-us/graph/api/resources/message?view=graph-rest-1.0
    class Message
      extend Dry::Initializer

      option :body, Types.DryConstructor(ItemBody)
      option :body_preview
      option :conversation_id
      option :from, Types.DryConstructor(Recipient)
      option :has_attachments, Types::Bool
      option :id
      option :internet_message_id
      option :importance
      option :is_draft, Types::Bool
      option :is_read, Types::Bool
      option :received_date_time, Types.Instance(DateTime)
      option :sent_date_time, Types.Instance(DateTime)
      option :single_value_extended_properties, Types.Array(Types.DryConstructor(SingleValueExtendedProperty)) | Types::Nil, optional: true
      option :subject
      option :to_recipients, Types.Array(Types.DryConstructor(Recipient))
      option :cc_recipients, Types.Array(Types.DryConstructor(Recipient)), optional: true
      option :bcc_recipients, Types.Array(Types.DryConstructor(Recipient)), optional: true
      option :unique_body, Types.DryConstructor(ItemBody), optional: true

      def in_reply_to_id
        single_value_extended_properties
          &.find { |svep| svep.id == SingleValueExtendedProperty::ID_PR_IN_REPLY_TO_ID }
          &.value
      end
    end
  end
end
