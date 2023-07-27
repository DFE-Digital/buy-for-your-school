RSpec.describe GetEntry do
  subject(:service) { described_class.new(entry_id:) }

  let(:entry_id) { "1a2b3c4d5" }

  describe "#call" do
    it "requests and returns the required entry from Contentful" do
      entry = double(Contentful::Entry, id: entry_id)
      allow(stub_client).to receive(:by_id).with(entry_id).and_return(entry)

      expect(service.call).to eq entry
    end

    context "when the Contentful entry cannot be found" do
      let(:entry_id) { "345vsdf7" }

      it "raises an error" do
        allow(stub_client).to receive(:by_id).with(entry_id).and_return(nil)

        expect { service.call }.to raise_error(GetEntry::EntryNotFound, "345vsdf7")
      end
    end
  end
end
