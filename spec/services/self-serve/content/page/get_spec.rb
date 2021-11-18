RSpec.describe Content::Page::Get do
  subject(:service) { described_class.new(page_entry_id: page_entry_id, client: stub_client) }

  let(:page_entry_id) { "page_entry_id" }

  # rubocop:disable RSpec/AnyInstance
  describe "#call" do
    it "returns a Contentful::Entry" do
      allow_any_instance_of(GetEntry).to receive(:call).and_return(instance_double(Contentful::Entry))

      expect(service.call).not_to be_nil
    end

    context "when the page entry cannot be found" do
      it "sends a message to Rollbar" do
        allow_any_instance_of(GetEntry).to receive(:call).and_raise(GetEntry::EntryNotFound)

        expect(Rollbar).to receive(:error)
          .with("A Contentful page entry was not found",
                contentful_url: "contentful api_url",
                contentful_space_id: "contentful space",
                contentful_environment: "contentful environment",
                contentful_entry_id: "page_entry_id")
          .and_call_original

        expect { service.call }.to raise_error GetEntry::EntryNotFound
      end
    end
  end
  # rubocop:enable RSpec/AnyInstance
end
