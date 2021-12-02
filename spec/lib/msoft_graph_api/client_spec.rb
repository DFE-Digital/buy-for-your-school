require "spec_helper"

describe MsoftGraphApi::Client do
  subject(:client) { described_class.new(client_session) }

  let(:user_id) { "USER-ID" }
  let(:client_session) { MsoftGraphApi::ClientSession.new("ACCESS-TOKEN") }

  describe "#list_mail_folders" do
    context "when two mail folders exist for given user" do
      let(:graph_api_response) do
        {
          "value" => [
            { "mailFolder" => 1 },
            { "mailFolder" => 2 },
          ],
        }
      end

      before do
        allow(client_session).to receive(:graph_api_get)
          .with("users/#{user_id}/mailFolders")
          .and_return(graph_api_response)
      end

      it "returns a MailFolder for each result in the response" do
        mail_folder_1 = instance_double("MsoftGraphApi::Resource::MailFolder")
        mail_folder_2 = instance_double("MsoftGraphApi::Resource::MailFolder")

        allow(MsoftGraphApi::Resource::MailFolder).to receive(:from_payload).with(graph_api_response["value"].last).and_return(mail_folder_2)
        allow(MsoftGraphApi::Resource::MailFolder).to receive(:from_payload).with(graph_api_response["value"].first).and_return(mail_folder_1)

        expect(client.list_mail_folders(user_id)).to match_array([mail_folder_1, mail_folder_2])
      end
    end
  end

  describe "#list_messages_in_folder" do
    let(:mail_folder_id) { "MAIL_FOLDER_1" }
    let(:graph_api_response) do
      {
        "value" => [
          { "message" => 1 },
          { "message" => 2 },
        ],
      }
    end

    before do
      allow(client_session).to receive(:graph_api_get)
        .with("users/#{user_id}/mailFolders/#{mail_folder_id}")
        .and_return(graph_api_response)
    end

    it "returns a MailFolder for each result in the response" do
      message_1 = instance_double("MsoftGraphApi::Resource::Message")
      message_2 = instance_double("MsoftGraphApi::Resource::Message")

      allow(MsoftGraphApi::Resource::Message).to receive(:from_payload).with(graph_api_response["value"].last).and_return(message_2)
      allow(MsoftGraphApi::Resource::Message).to receive(:from_payload).with(graph_api_response["value"].first).and_return(message_1)

      expect(client.list_messages_in_folder(user_id, mail_folder_id)).to match_array([message_1, message_2])
    end
  end
end
