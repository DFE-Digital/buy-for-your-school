require "spec_helper"

describe MicrosoftGraph::Transformer::MailFolder do
  describe "transformation into its resource" do
    it "maps response json field names to object fields" do
      payload = {
        "childFolderCount" => 1,
        "displayName" => "value_displayName",
        "id" => "value_id",
        "isHidden" => true,
        "parentFolderId" => "value_parentFolderId",
        "totalItemCount" => 12,
        "unreadItemCount" => 10,
      }

      mail_folder = described_class.transform(payload, into: MicrosoftGraph::Resource::MailFolder)

      expect(mail_folder.child_folder_count).to eq(1)
      expect(mail_folder.display_name).to eq("value_displayName")
      expect(mail_folder.id).to eq("value_id")
      expect(mail_folder.is_hidden).to eq(true)
      expect(mail_folder.parent_folder_id).to eq("value_parentFolderId")
      expect(mail_folder.total_item_count).to eq(12)
      expect(mail_folder.unread_item_count).to eq(10)
    end
  end
end
