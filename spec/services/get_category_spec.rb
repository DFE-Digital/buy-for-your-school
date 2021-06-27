require "rails_helper"

RSpec.describe GetCategory do
  describe "#call" do
    it "returns a Contenetful::Entry for the category_entry_id" do
      stub_contentful_category(
        fixture_filename: "static-content.json",
        stub_sections: false,
      )
      result = described_class.new(category_entry_id: "contentful-category-entry").call
      expect(result.id).to eql("contentful-category-entry")
    end

    context "when the category entry cannot be found" do
      it "sends a message to rollbar" do
        contentful_connector = instance_double(ContentfulConnector)
        allow(ContentfulConnector).to receive(:new)
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

    context "when the Liquid contents are invalid (using the gems own parser)" do
      it "raises an error" do
        stub_contentful_category(fixture_filename: "category-with-invalid-liquid-template.json")

        expect {
          described_class.new(category_entry_id: "contentful-category-entry").call
        }.to raise_error(GetCategory::InvalidLiquidSyntax)
      end

      it "sends an error to rollbar" do
        stub_contentful_category(fixture_filename: "category-with-invalid-liquid-template.json")

        expect(Rollbar).to receive(:error)
          .with("A user couldn't start a journey because of an invalid Specification",
                contentful_url: ENV["CONTENTFUL_URL"],
                contentful_space_id: ENV["CONTENTFUL_SPACE"],
                contentful_environment: ENV["CONTENTFUL_ENVIRONMENT"],
                contentful_entry_id: "contentful-category-entry").and_call_original

        expect {
          described_class.new(category_entry_id: "contentful-category-entry").call
        }.to raise_error(GetCategory::InvalidLiquidSyntax)
      end
    end

    context "when there are multiple specification fields on the category (specification_template_x)" do
      it "returns a merged and sorted set separated by newlines" do
        stub_contentful_category(
          fixture_filename: "multiple-specification-templates.json",
          stub_sections: false,
        )
        result = described_class.new(category_entry_id: "contentful-category-entry").call

        # It should leave the original fields as they were
        expect(result.specification_template).to eql("<article id='specification'>\n  <section>\n   <p>Part 1</p>\n  </section>\n</article>")
        expect(result.specification_template_part2).to eql("<article id='specification'>\n  <section>\n    <p>Part 2</p>\n  </section>\n</article>")

        # The result object can be asked for the combined specification template
        expect(result.combined_specification_template)
          .to eql("<article id='specification'>\n  <section>\n   <p>Part 1</p>\n  </section>\n</article>\n<article id='specification'>\n  <section>\n    <p>Part 2</p>\n  </section>\n</article>")
      end

      it "validates both specification field inputs" do
        stub_contentful_category(
          fixture_filename: "multiple-specification-templates.json",
          stub_sections: false,
        )

        expect(Liquid::Template).to receive(:parse).with(
          "<article id='specification'>\n  <section>\n   <p>Part 1</p>\n  </section>\n</article>\n<article id='specification'>\n  <section>\n    <p>Part 2</p>\n  </section>\n</article>",
          error_mode: :strict,
        )

        _result = described_class.new(category_entry_id: "contentful-category-entry").call
      end
    end
  end
end
