module MsoftGraphApi
  module Resource
    # https://docs.microsoft.com/en-us/graph/api/resources/mailfolder?view=graph-rest-1.0
    class MailFolder
      extend Dry::Initializer

      option :child_folder_count, Types::Params::Integer, optional: true
      option :display_name, Types::Params::String, optional: true
      option :id, Types::Params::String, optional: true
      option :is_hidden, Types::Params::Bool, optional: true
      option :parent_folder_id, Types::Params::String, optional: true
      option :total_item_count, Types::Params::Integer, optional: true
      option :unread_item_count, Types::Params::Integer, optional: true

      def self.from_payload(payload)
        new(
          child_folder_count: payload["childFolderCount"],
          display_name: payload["displayName"],
          id: payload["id"],
          is_hidden: payload["isHidden"],
          parent_folder_id: payload["parentFolderId"],
          total_item_count: payload["totalItemCount"],
          unread_item_count: payload["unreadItemCount"],
        )
      end
    end
  end
end
