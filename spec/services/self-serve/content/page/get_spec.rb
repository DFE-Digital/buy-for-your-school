RSpec.describe Content::Page::Get do
  subject(:service) { described_class.new(page_entry_id: page_entry_id, client: client) }

  let(:page_entry_id) { "page_entry_id" }
  let(:client) { stub_client }

  describe "#call" do
    it "returns a Contentful::Entry" do
      allow(client).to receive(:by_id).with(page_entry_id).and_return(instance_double(Contentful::Entry))

      expect(service.call).not_to eq :not_found
    end

    context "when the page entry cannot be found" do
      it "sends a message to Rollbar" do
        allow(client).to receive(:by_id).with(page_entry_id).and_return(nil)

        expect(Rollbar).to receive(:error)
          .with("A Contentful page entry was not found",
                contentful_url: "contentful api_url",
                contentful_space_id: "contentful space",
                contentful_environment: "contentful environment",
                contentful_entry_id: "page_entry_id")
          .and_call_original

        expect(service.call).to eq :not_found
      end
    end
  end
end
