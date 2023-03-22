module Messages
  class SendNewMessage
    include Wisper::Publisher

    def call(support_case_id:, message_options:)
      Support::Messages::Outlook::SendNewMessage.new(**message_options).call

      broadcast(:contact_to_school_made, { support_case_id:, contact_type: "sending a new message" })
    end
  end
end
