module MicrosoftGraph
  module Resource
    # https://docs.microsoft.com/en-us/graph/api/resources/message?view=graph-rest-1.0
    class Recipient
      extend Dry::Initializer

      option :email_address, Types.DryConstructor(EmailAddress)
    end
  end
end
