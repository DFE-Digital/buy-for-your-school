require "spec_helper"

describe MicrosoftGraph::Resource::ItemBody do
  describe ".from_payload" do
    it "maps response json field names to object fields" do
      payload = {
        "content" => "Content Here",
        "contentType" => "html",
      }

      item_body = described_class.from_payload(payload)

      expect(item_body.content).to eq("Content Here")
      expect(item_body.content_type).to eq("html")
    end
  end
end
