module MicrosoftGraph
  module Resource
    # https://docs.microsoft.com/en-us/graph/api/resources/fileattachment?view=graph-rest-1.0
    class Attachment
      extend Dry::Initializer

      option :content_bytes, Types::String
      option :content_id, Types::String | Types::Nil, optional: true
      option :content_type, Types::String
      option :id, Types::String
      option :is_inline, Types::Bool
      option :last_modified_date_time, Types.Instance(DateTime)
      option :name, Types::String
      option :size, Types::Integer
    end
  end
end

