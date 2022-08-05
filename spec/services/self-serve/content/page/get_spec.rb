RSpec.describe Content::Page::Get do
  subject(:service) { described_class.new(entry_id:, client:) }

  let(:entry_id) { "entry_id" }
  let(:client) { stub_client }

  describe "#call" do
    it "returns a Contentful::Entry" do
      allow(client).to receive(:by_id).with(entry_id).and_return(Contentful::Entry.new({}, {}))

      expect(service.call).to be_kind_of(Contentful::Entry)
    end

    context "when the page entry cannot be found" do
      it "sends a message to Rollbar" do
        allow(client).to receive(:by_id).with(entry_id).and_return(nil)

        expect(Rollbar).to receive(:error)
          .with("A Contentful page entry was not found",
                contentful_url: "contentful api_url",
                contentful_space_id: "contentful space",
                contentful_environment: "contentful environment",
                contentful_entry_id: "entry_id")
          .and_call_original

        expect(service.call).to eq :not_found
      end
    end
  end
end
