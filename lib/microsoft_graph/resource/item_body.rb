module MicrosoftGraph
  module Resource
    # https://docs.microsoft.com/en-us/graph/api/resources/itembody?view=graph-rest-1.0
    class ItemBody
      extend Dry::Initializer

      option :content, Types::String
      option :content_type, Types::String
    end
  end
end
