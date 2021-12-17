module MicrosoftGraph
  module Resource
    # https://docs.microsoft.com/en-us/graph/api/resources/emailaddress?view=graph-rest-1.0
    class EmailAddress
      extend Dry::Initializer

      option :address, Types::String
      option :name, Types::String

      def to_s
        address
      end
    end
  end
end
