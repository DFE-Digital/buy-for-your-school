module MicrosoftGraph
  # Graph API v1.0
  class Client
    attr_reader :client_session

    def initialize(client_session)
      @client_session = client_session
    end

    # https://docs.microsoft.com/en-us/graph/api/user-list-mailfolders?view=graph-rest-1.0
    def list_mail_folders(user_id)
      results = client_session.graph_api_get("users/#{user_id}/mailFolders")
      Transformer::MailFolder.transform_collection(results, into: Resource::MailFolder)
    end

    # https://docs.microsoft.com/en-us/graph/api/mailfolder-list-messages?view=graph-rest-1.0
    def list_messages_in_folder(user_id, mail_folder, query: [])
      message_fields = %w[
        internetMessageHeaders
        internetMessageId
        importance
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
      results = client_session.graph_api_get("users/#{user_id}/mailFolders('#{mail_folder}')/messages".concat(format_query(query)))
      Transformer::Message.transform_collection(results, into: Resource::Message)
    end

    # https://docs.microsoft.com/en-us/graph/api/message-update?view=graph-rest-1.0&tabs=http
    def mark_message_as_read(user_id, mail_folder, message_ms_id)
      body = { isRead: true }.to_json
      client_session.graph_api_patch("users/#{user_id}/mailFolders('#{mail_folder}')/messages/#{message_ms_id}", body)
    end

    # https://docs.microsoft.com/en-us/graph/api/message-list-attachments?view=graph-rest-1.0&tabs=http
    def get_file_attachments(user_id, message_ms_id)
      results = client_session.graph_api_get("users/#{user_id}/messages/#{message_ms_id}/attachments")
      file_attachments = results.select { |item| item["@odata.type"] == "#microsoft.graph.fileAttachment" }
      Transformer::Attachment.transform_collection(file_attachments, into: Resource::Attachment)
    end

    # https://docs.microsoft.com/en-us/graph/api/user-post-messages?view=graph-rest-1.0&tabs=http
    def create_draft_message(user_id, subject:, html_body:, headers: {})
      # set importance to high
      # set inferenceClassification to focused
      # set case ref header
      # set immutible id header
    end

    # https://docs.microsoft.com/en-us/graph/api/message-createreply?view=graph-rest-1.0&tabs=http
    def create_draft_reply_message
    end

    # https://docs.microsoft.com/en-us/graph/api/message-send?view=graph-rest-1.0&tabs=http
    def send_message(user_id, message_ms_id)
      json = client_session.graph_api_post("users/#{user_id}/messages/#{message_ms_id}/send")
    end

  private

    def format_query(query_parts)
      query_parts.any? ? "?".concat(query_parts.join("&")) : ""
    end
  end
end
