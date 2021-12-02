module MsoftGraphApi
  module Resource
    # https://docs.microsoft.com/en-us/graph/api/resources/message?view=graph-rest-1.0
    class Recipient
      extend Dry::Initializer

      option :email_address, Types.Instance(EmailAddress)

      def self.from_payload(payload)
        email_address = EmailAddress.from_payload(payload["emailAddress"])

        new(email_address: email_address)
      end
    end
  end
end
