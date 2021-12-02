module MsoftGraphApi
  module Resource
    # https://docs.microsoft.com/en-us/graph/api/resources/itembody?view=graph-rest-1.0
    class ItemBody
      extend Dry::Initializer

      option :content, Types::String
      option :content_type, Types::String

      def self.from_payload(payload)
        new(
          content: payload["content"],
          content_type: payload["contentType"],
        )
      end
    end
  end
end
