require "spec_helper"

describe MicrosoftGraph::Transformer::Attachment do
  describe "transformation into its resource" do
    it "maps response json field names to object fields" do
      payload = {
        "contentBytes" => "1024",
        "contentId" => "1",
        "contentLocation" => "1",
        "contentType" => "1",
        "id" => "1",
        "isInLine" => true,
        "lastModifiedDateTime" => "2021-12-07T15:00:00Z",
        "name" => "example file",
        "size" => 1,
      }

      attachment = described_class.transform(payload, into: MicrosoftGraph::Resource::Attachment)

      expect(attachment.content_bytes).to eq("1024")
      expect(attachment.content_id).to eq("1")
      expect(attachment.content_location).to eq("1")
      expect(attachment.content_type).to eq("1")
      expect(attachment.id).to eq("1")
      expect(attachment.is_in_line).to eq(true)
      expect(attachment.last_modified_date_time).to eq(Time.zone.parse(payload["lastModifiedDateTime"]))
      expect(attachment.name).to eq("example file")
      expect(attachment.size).to eq(1)
    end
  end
end
