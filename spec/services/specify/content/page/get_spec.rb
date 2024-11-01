RSpec.describe Content::Page::Get do
  subject(:service) { described_class.new(entry_id:, client:) }

  let(:entry_id) { "entry_id" }
  let(:client) { stub_client }

  describe "#call" do
    it "returns a Contentful::Entry" do
      allow(client).to receive(:by_id).with(entry_id).and_return(Contentful::Entry.new({}, {}))

      expect(service.call).to be_a(Contentful::Entry)
    end

    context "when the page entry cannot be found" do
      it "returns :not_found" do
        allow(client).to receive(:by_id).with(entry_id).and_return(nil)

        expect(service.call).to eq :not_found
      end
    end
  end
end
