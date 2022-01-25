require "spec_helper"

describe MicrosoftGraph::Transformer::BasePipe do
  describe ".transform_collection" do
    it "calls .transform for each element provided" do
      allow(described_class).to receive(:transform).and_return(nil)

      response_item_1 = double
      response_item_2 = double

      described_class.transform_collection([response_item_1, response_item_2], into: :resource)

      expect(described_class).to have_received(:transform).with(response_item_1, into: :resource).once
      expect(described_class).to have_received(:transform).with(response_item_2, into: :resource).once
    end
  end
end
