require "rails_helper"

RSpec.describe GetEntry do
  let(:entry_id) { "1a2b3c4d5" }

  let(:connector) { stub_contentful_connector }

  describe "#call" do
    it "requests and returns the required entry from Contentful" do
      entry = double(Contentful::Entry, id: entry_id)

      allow(connector).to receive(:by_id).with(entry_id).and_return(entry)

      result = described_class.new(entry_id: entry_id).call

      expect(result).to eq entry
    end

    context "when the Contentful entry cannot be found" do
      it "returns an error message" do
        missing_entry_id = "345vsdf7"

        allow(connector).to receive(:by_id).with(missing_entry_id).and_return(nil)

        expect { described_class.new(entry_id: missing_entry_id).call }
          .to raise_error(GetEntry::EntryNotFound)
      end

      it "raises a rollbar event" do
        allow(connector).to receive(:by_id).with(anything).and_return(nil)

        expect(Rollbar).to receive(:warning)
          .with("The following Contentful entry identifier could not be found.",
                contentful_url: ENV["CONTENTFUL_URL"],
                contentful_space_id: ENV["CONTENTFUL_SPACE"],
                contentful_environment: ENV["CONTENTFUL_ENVIRONMENT"],
                contentful_entry_id: "123")
          .and_call_original
        expect { described_class.new(entry_id: "123").call }
          .to raise_error(GetEntry::EntryNotFound)
      end
    end
  end
end
