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
      Transformer::MailFolder.transform_collection(json["value"], into: Resource::MailFolder)
    end

    # https://docs.microsoft.com/en-us/graph/api/mailfolder-list-messages?view=graph-rest-1.0
    def list_messages_in_folder(user_id, mail_folder, query: [])
      message_fields = %w[
        internetMessageHeaders
        body
        bodyPreview
        conversationId
        subject
        receivedDateTime
        sentDateTime
        from
        toRecipients
        isRead
        isDraft
        hasAttachments
      ]

      query = Array(query).push("$select=#{message_fields.join(',')}")
      json = client_session.graph_api_get("users/#{user_id}/mailFolders('#{mail_folder}')/messages".concat(format_query(query)))
      Transformer::Message.transform_collection(json["value"], into: Resource::Message)
    end

    # https://docs.microsoft.com/en-us/graph/api/message-update?view=graph-rest-1.0&tabs=http
    def mark_message_as_read(user_id, mail_folder, message_ms_id)
      body = { isRead: true }.to_json
      client_session.graph_api_patch("users/#{user_id}/mailFolders('#{mail_folder}')/messages/#{message_ms_id}", body)
    end

    # https://docs.microsoft.com/en-us/graph/api/message-list-attachments?view=graph-rest-1.0&tabs=http
    def get_file_attachments(user_id, message_ms_id)
      json = client_session.graph_api_get("users/#{user_id}/messages/#{message_ms_id}/attachments")
      file_attachments = json["value"].select { |item| item["@odata.type"] == "#microsoft.graph.fileAttachment" }
      Transformer::Attachment.transform_collection(file_attachments, into: Resource::Attachment)
    end

    # https://docs.microsoft.com/en-us/graph/api/user-post-messages?view=graph-rest-1.0&tabs=http
    def create_message
      # set importance to high
      # set inferenceClassification to focused
    end

  private

    def format_query(query_parts)
      query_parts.any? ? "?".concat(query_parts.join("&")) : ""
    end
  end
end
