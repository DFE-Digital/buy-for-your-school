module MicrosoftGraph
  # Graph API v1.0
  class Client
    attr_reader :client_session

    MESSAGE_SELECT_FIELDS = %w[
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
    ].freeze

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
      query = Array(query)
        .push("$select=#{MESSAGE_SELECT_FIELDS.join(',')}")
        .push("$expand=singleValueExtendedProperties($filter=id eq '#{Resource::SingleValueExtendedProperty::ID_PR_IN_REPLY_TO_ID}')")

      results = client_session.graph_api_get("users/#{user_id}/mailFolders('#{mail_folder}')/messages".concat(format_query(query)))

      Transformer::Message.transform_collection(results, into: Resource::Message)
    end

    # https://docs.microsoft.com/en-us/graph/api/user-list-messages?view=graph-rest-1.0&tabs=http
    def list_messages(user_id, query: [])
      client_session.graph_api_get("users/#{user_id}/messages".concat(format_query(query)))
      # results are not transformed
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

    # https://docs.microsoft.com/en-us/graph/api/message-createreply?view=graph-rest-1.0&tabs=http
    def create_reply_message(user_id:, reply_to_id:, http_headers: {})
      response = client_session.graph_api_post("users/#{user_id}/messages/#{reply_to_id}/createReply", nil, http_headers)
      Transformer::Message.transform(response, into: Resource::Message)
    end

    # https://docs.microsoft.com/en-us/graph/api/user-post-messages?view=graph-rest-1.0&tabs=http
    def create_message(user_id:, request_body: {}, http_headers: {})
      response = client_session.graph_api_post(
        "users/#{user_id}/messages",
        request_body.to_json,
        http_headers.merge(
          "Content-Type" => "application/json",
        ),
      )
      response["id"]
    end

    # https://docs.microsoft.com/en-us/graph/api/message-post-attachments?view=graph-rest-1.0&tabs=http#example-file-attachment
    def add_file_attachment_to_message(user_id:, message_id:, file_attachment:)
      request_body = {
        "@odata.type" => "#microsoft.graph.fileAttachment",
        "name" => file_attachment.name,
        "contentBytes" => file_attachment.content_bytes,
        "contentType" => file_attachment.content_type,
      }.to_json

      http_headers = {
        "Content-Type" => "application/json",
      }

      client_session.graph_api_post("users/#{user_id}/messages/#{message_id}/attachments", request_body, http_headers)
    end

    # https://docs.microsoft.com/en-us/graph/api/message-update?view=graph-rest-1.0&tabs=http
    def update_message(user_id:, message_id:, details:, http_headers: {})
      response = client_session.graph_api_patch(
        "users/#{user_id}/messages/#{message_id}",
        details.to_json,
        http_headers.merge(
          "Content-Type" => "application/json",
        ),
      )
      Transformer::Message.transform(response, into: Resource::Message)
    end

    # https://docs.microsoft.com/en-us/graph/api/message-send?view=graph-rest-1.0&tabs=http
    def send_message(user_id:, message_id:, http_headers: {})
      client_session.graph_api_post("users/#{user_id}/messages/#{message_id}/send", nil, http_headers)
    end

  private

    def format_query(query_parts)
      query_parts.any? ? "?".concat(query_parts.join("&")) : ""
    end
  end
end
