module MicrosoftGraph
  module Resource
    # https://docs.microsoft.com/en-us/graph/api/resources/fileattachment?view=graph-rest-1.0
    class Attachment
      extend Dry::Initializer

      option :content_bytes, Types::String
      option :content_id, Types::String
      option :content_location, Types::String
      option :content_type, Types::String
      option :id, Types::String
      option :is_in_line, Types::Bool
      option :last_modified_date_time, Types.Instance(DateTime)
      option :name, Types::String
      option :size, Types::Integer

      def self.from_payload(payload)
        new(
          content_bytes: payload["contentBytes"],
          content_id: payload["contentId"],
          content_location: payload["contentLocation"],
          content_type: payload["contentType"],
          id: payload["id"],
          is_in_line: payload["isInLine"],
          last_modified_date_time: DateTime.parse(payload["lastModifiedDateTime"]),
          name: payload["name"],
          size: payload["size"],
        )
      end
    end
  end
end
