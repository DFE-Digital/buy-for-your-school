require "spec_helper"

describe MsoftGraphApi::Client do
  subject(:client) { described_class.new(client_session) }
  let(:client_session) { MsoftGraphApi::ClientSession.new("ACCESS-TOKEN") }

  describe "#list_mail_folders" do
    let(:user_id) { "USER-ID" }

    context "when two mail folders exist for given user" do
      before do
        allow(client_session).to receive(:graph_api_get)
          .with("users/#{user_id}/mailFolders")
          .and_return(JSON.parse(graph_api_response))
      end

      let(:graph_api_response) do
        <<-JSON
        {
          "@odata.context": "https://graph.microsoft.com/beta/$metadata#users('#{user_id}')/mailFolders",
          "value": [
            {
              "childFolderCount": 2,
              "displayName": "First Mail Folder",
              "id": "AAMkADg3NTY5MDg4LWMzYmQtNDQzNi05OTgwLWAAA=",
              "isHidden": false,
              "parentFolderId": "FOLDER-A",
              "totalItemCount": 12,
              "unreadItemCount": 3
            },
            {
              "childFolderCount": 0,
              "displayName": "Second Mail Folder",
              "id": "AAMkADg3NTY5MDg4LWMzYmQtNDQzNi05OTgwLWAAB=",
              "isHidden": true,
              "parentFolderId": "FOLDER-B",
              "totalItemCount": 100,
              "unreadItemCount": 50
            }
          ]
        }
        JSON
      end

      it "returns each mail folder as MailFolder objects" do
        results = client.list_mail_folders(user_id)
        expect(results.count).to eq(2)

        mail_folder_1 = results.first
        expect(mail_folder_1.child_folder_count).to eq(2)
        expect(mail_folder_1.display_name).to eq("First Mail Folder")
        expect(mail_folder_1.id).to eq("AAMkADg3NTY5MDg4LWMzYmQtNDQzNi05OTgwLWAAA=")
        expect(mail_folder_1.is_hidden).to eq(false)
        expect(mail_folder_1.parent_folder_id).to eq("FOLDER-A")
        expect(mail_folder_1.total_item_count).to eq(12)
        expect(mail_folder_1.unread_item_count).to eq(3)

        mail_folder_2 = results.last
        expect(mail_folder_2.child_folder_count).to eq(0)
        expect(mail_folder_2.display_name).to eq("Second Mail Folder")
        expect(mail_folder_2.id).to eq("AAMkADg3NTY5MDg4LWMzYmQtNDQzNi05OTgwLWAAB=")
        expect(mail_folder_2.is_hidden).to eq(true)
        expect(mail_folder_2.parent_folder_id).to eq("FOLDER-B")
        expect(mail_folder_2.total_item_count).to eq(100)
        expect(mail_folder_2.unread_item_count).to eq(50)
      end
    end
  end
end