require "rails_helper"

RSpec.describe GetCategory do
  describe "#call" do
    it "returns a Contenetful::Entry for the category_entry_id" do
      stub_contentful_category(fixture_filename: "static-content.json")
      result = described_class.new(category_entry_id: "contentful-category-entry").call
      expect(result.id).to eql("contentful-category-entry")
    end

    context "when the category entry cannot be found" do
      it "sends a message to rollbar" do
        contentful_connector = instance_double(ContentfulConnector)
        expect(ContentfulConnector).to receive(:new)
          .and_return(contentful_connector)

        allow(contentful_connector).to receive(:get_entry_by_id)
          .with(anything)
          .and_return(nil)

        expect(Rollbar).to receive(:error)
          .with("A Contentful category entry was not found",
            contentful_url: ENV["CONTENTFUL_URL"],
            contentful_space_id: ENV["CONTENTFUL_SPACE"],
            contentful_environment: ENV["CONTENTFUL_ENVIRONMENT"],
            contentful_entry_id: "a-category-id-that-does-not-exist")
          .and_call_original

        expect {
          described_class.new(category_entry_id: "a-category-id-that-does-not-exist").call
        }.to raise_error(GetEntry::EntryNotFound)
      end
    end
  end
end
