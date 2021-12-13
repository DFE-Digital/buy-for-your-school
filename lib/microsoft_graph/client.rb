module MicrosoftGraph
  # Graph API v1.0
  class Client
    attr_reader :client_session

    def initialize(client_session)
      @client_session = client_session
    end

    # https://docs.microsoft.com/en-us/graph/api/user-list-mailfolders?view=graph-rest-1.0
    def list_mail_folders(user_id)
      json = client_session.graph_api_get("users/#{user_id}/mailFolders")
      raw_mail_folders = json["value"]
      raw_mail_folders.map { |mail_folder| Resource::MailFolder.from_payload(mail_folder) }
    end

    # https://docs.microsoft.com/en-us/graph/api/mailfolder-list-messages?view=graph-rest-1.0
    def list_messages_in_folder(user_id, mail_folder_id)
      json = client_session.graph_api_get("users/#{user_id}/mailFolders/#{mail_folder_id}/messages")
      raw_messages = json["value"]
      raw_messages.map { |message| Resource::Message.from_payload(message) }
    end

    # https://docs.microsoft.com/en-us/graph/api/message-update?view=graph-rest-1.0&tabs=http
    def mark_message_as_read(user_id, mail_folder_id, message_ms_id)
      body = { isRead: true }.to_json
      client_session.graph_api_post("users/#{user_id}/mailFolders/#{mail_folder_id}/messages/#{message_ms_id}", body)
    end
  end
end
