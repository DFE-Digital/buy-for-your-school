require "spec_helper"

describe MicrosoftGraph::Client do
  subject(:client) { described_class.new(client_session) }

  let(:user_id) { "USER-ID" }
  let(:client_session) { MicrosoftGraph::ClientSession.new(double) }

  describe "#list_mail_folders" do
    context "when two mail folders exist for given user" do
      let(:graph_api_response) do
        [
          { "mailFolder" => 1 },
          { "mailFolder" => 2 },
        ]
      end

      before do
        allow(client_session).to receive(:graph_api_get)
          .with("users/#{user_id}/mailFolders")
          .and_return(graph_api_response)
      end

      it "returns a MailFolder for each result in the response" do
        mail_folder_1 = instance_double("MicrosoftGraph::Resource::MailFolder")
        mail_folder_2 = instance_double("MicrosoftGraph::Resource::MailFolder")

        allow(MicrosoftGraph::Transformer::MailFolder).to receive(:transform_collection)
          .with(graph_api_response, into: MicrosoftGraph::Resource::MailFolder)
          .and_return([mail_folder_1, mail_folder_2])

        expect(client.list_mail_folders(user_id)).to match_array([mail_folder_1, mail_folder_2])
      end
    end
  end

  describe "#list_messages_in_folder" do
    let(:mail_folder) { "MAIL_FOLDER_1" }
    let(:graph_api_response) do
      [
        { "message" => 1 },
        { "message" => 2 },
      ]
    end

    before do
      allow(client_session).to receive(:graph_api_get)
        .with("users/#{user_id}/mailFolders('#{mail_folder}')/messages?$select=internetMessageHeaders,internetMessageId,importance,body,bodyPreview,conversationId,subject,receivedDateTime,sentDateTime,from,toRecipients,ccRecipients,bccRecipients,isRead,isDraft,hasAttachments,uniqueBody&$expand=singleValueExtendedProperties($filter=id eq 'String 0x1042')")
        .and_return(graph_api_response)
    end

    it "returns a Message for each result in the response" do
      message_1 = instance_double("MicrosoftGraph::Resource::Message")
      message_2 = instance_double("MicrosoftGraph::Resource::Message")

      allow(MicrosoftGraph::Transformer::Message).to receive(:transform_collection)
          .with(graph_api_response, into: MicrosoftGraph::Resource::Message)
          .and_return([message_1, message_2])

      expect(client.list_messages_in_folder(user_id, mail_folder)).to match_array([message_1, message_2])
    end

    context "when query parameter is passed" do
      it "appends them to the request url" do
        allow(client_session).to receive(:graph_api_get).and_return(graph_api_response)

        allow(MicrosoftGraph::Transformer::Message).to receive(:transform_collection)
          .with(anything, into: anything)
          .and_return(double)

        client.list_messages_in_folder(user_id, mail_folder, query: ["$filter=sentDateTime eq X", "$orderBy=receivedDateTime desc"])

        expect(client_session).to have_received(:graph_api_get)
          .with("users/#{user_id}/mailFolders('#{mail_folder}')/messages?$filter=sentDateTime eq X&$orderBy=receivedDateTime desc&$select=internetMessageHeaders,internetMessageId,importance,body,bodyPreview,conversationId,subject,receivedDateTime,sentDateTime,from,toRecipients,ccRecipients,bccRecipients,isRead,isDraft,hasAttachments,uniqueBody&$expand=singleValueExtendedProperties($filter=id eq 'String 0x1042')")
      end
    end
  end

  describe "#mark_message_as_read" do
    let(:mail_folder) { "MAIL_FOLDER_1" }
    let(:message_id) { "MESSAGE_ID" }
    let(:graph_api_response) do
      {
        "receivedDateTime" => Time.zone.now,
        "sentDateTime" => Time.zone.now,
        "isRead" => true,
      }
    end

    before do
      allow(client_session).to receive(:graph_api_patch)
        .with("users/#{user_id}/mailFolders('#{mail_folder}')/messages/#{message_id}", { isRead: true }.to_json)
        .and_return(graph_api_response)
    end

    it "returns a response indicating that the message has updated the isRead property to true" do
      expect(client.mark_message_as_read(user_id, mail_folder, message_id)).to eql(graph_api_response)
    end
  end

  describe "#get_file_attachments" do
    let(:message_id) { "MESSAGE_ID" }

    let(:graph_api_response) do
      [
        { "@odata.type" => "#microsoft.graph.fileAttachment",
          "contentType": "contentType-value",
          "contentLocation": "contentLocation-value",
          "contentBytes": "contentBytes-value",
          "contentId": "null",
          "lastModifiedDateTime": "datetime-value",
          "id": "id-value",
          "isInline": false,
          "name": "example-file-1",
          "size": 99 },
        { "@odata.type" => "#microsoft.graph.fileAttachment",
          "contentType": "contentType-value",
          "contentLocation": "contentLocation-value",
          "contentBytes": "contentBytes-value",
          "contentId": "null",
          "lastModifiedDateTime": "datetime-value",
          "id": "id-value",
          "isInline": false,
          "name": "example-file-2",
          "size": 99 },
      ]
    end

    before do
      allow(client_session).to receive(:graph_api_get)
                                 .with("users/#{user_id}/messages/#{message_id}/attachments")
                                 .and_return(graph_api_response)
    end

    it "returns a MailFolder for each result in the response" do
      file_1 = instance_double("MicrosoftGraph::Resource::Attachment")
      file_2 = instance_double("MicrosoftGraph::Resource::Attachment")

      allow(MicrosoftGraph::Transformer::Attachment).to receive(:transform_collection)
                                                       .with(graph_api_response, into: MicrosoftGraph::Resource::Attachment)
                                                       .and_return([file_1, file_2])

      expect(client.get_file_attachments(user_id, message_id)).to match_array([file_1, file_2])
    end
  end

  describe "#create_reply_message" do
    let(:reply_to_id) { "REPLYING_TO_ID" }
    let(:http_headers) { { "headers" => "here" } }
    let(:graph_api_response) { { "id" => "NEW_DRAFT_MESSAGE_ID" } }
    let(:message) { double("message") }

    before do
      allow(client_session).to receive(:graph_api_post)
        .and_return(graph_api_response)

      allow(MicrosoftGraph::Transformer::UpdateMessage).to receive(:transform)
        .with(graph_api_response, into: MicrosoftGraph::Resource::Message)
        .and_return(message)
    end

    it "makes a post request to the API" do
      client.create_reply_message(user_id:, reply_to_id:, http_headers:)

      expect(client_session).to have_received(:graph_api_post).with(
        "users/#{user_id}/messages/#{reply_to_id}/createReply",
        nil,
        http_headers,
      )
    end

    it "returns the draft message from the api response" do
      expect(client.create_reply_message(user_id:, reply_to_id:, http_headers:)).to eq(message)
    end
  end

  describe "#create_message" do
    let(:http_headers) { { "Content-Type" => "application/json", "headers" => "here" } }
    let(:graph_api_response) { { "id" => "NEW_DRAFT_MESSAGE_ID" } }

    before do
      allow(client_session).to receive(:graph_api_post)
        .and_return(graph_api_response)
    end

    it "makes a post request to the API" do
      client.create_message(user_id:, http_headers:)

      expect(client_session).to have_received(:graph_api_post).with(
        "users/#{user_id}/messages",
        "{}",
        http_headers,
      )
    end

    it "returns the draft message from the api response" do
      expect(client.create_message(user_id:, http_headers:)).to eq("NEW_DRAFT_MESSAGE_ID")
    end
  end

  describe "#update_message" do
    let(:message_id) { "MESSAGE_ID" }
    let(:http_headers) { { "headers" => "here" } }
    let(:details) { { "details" => "here" } }
    let(:graph_api_response) { { "id" => message_id } }
    let(:message) { double("message") }

    before do
      allow(client_session).to receive(:graph_api_patch)
        .and_return(graph_api_response)

      allow(MicrosoftGraph::Transformer::UpdateMessage).to receive(:transform)
        .with(graph_api_response, into: MicrosoftGraph::Resource::Message)
        .and_return(message)
    end

    it "makes a patch request to the API" do
      client.update_message(user_id:, message_id:, details:, http_headers:)

      expect(client_session).to have_received(:graph_api_patch).with(
        "users/#{user_id}/messages/#{message_id}",
        details.to_json,
        http_headers.merge("Content-Type" => "application/json"),
      )
    end

    it "returns the message from the api response" do
      expect(client.update_message(user_id:, message_id:, details:, http_headers:)).to eq(message)
    end
  end

  describe "#send_message" do
    let(:message_id) { "MESSAGE_ID" }
    let(:http_headers) { {} }

    before do
      allow(client_session).to receive(:graph_api_post)
    end

    it "makes a post request to the API" do
      client.send_message(user_id:, message_id:, http_headers:)

      expect(client_session).to have_received(:graph_api_post).with(
        "users/#{user_id}/messages/#{message_id}/send",
        nil,
        http_headers,
      )
    end
  end

  describe "#add_file_attachment_to_message" do
    let(:message_id) { "MESSAGE_ID" }

    before do
      allow(client_session).to receive(:graph_api_post)
    end

    it "makes a post request to the API" do
      file = double("file_attachment", content_bytes: "XYZ", content_type: "text/plain", name: "xyz.txt")

      request_body = {
        "@odata.type" => "#microsoft.graph.fileAttachment",
        "name" => "xyz.txt",
        "contentBytes" => "XYZ",
        "contentType" => "text/plain",
      }

      client.add_file_attachment_to_message(user_id:, message_id:, file_attachment: file)

      expect(client_session).to have_received(:graph_api_post).with(
        "users/#{user_id}/messages/#{message_id}/attachments",
        request_body.to_json,
        { "Content-Type" => "application/json" },
      )
    end
  end

  describe "#list_messages" do
    let(:user_id) { "USER_ID" }

    before do
      allow(client_session).to receive(:graph_api_get)
    end

    it "calls the GET messages endpoint for a mailbox user" do
      client.list_messages(user_id)
      expect(client_session).to have_received(:graph_api_get).with("users/#{user_id}/messages")
    end
  end
end
