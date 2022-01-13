require "spec_helper"

describe MicrosoftGraph::Transformer::ItemBody do
  describe "transformation into its resource" do
    it "maps response json field names to object fields" do
      payload = {
        "content" => "Content Here",
        "contentType" => "html",
      }

      item_body = described_class.transform(payload, into: MicrosoftGraph::Resource::ItemBody)

      expect(item_body.content).to eq("Content Here")
      expect(item_body.content_type).to eq("html")
    end
  end
end
