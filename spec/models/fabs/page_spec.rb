require "rails_helper"

RSpec.describe FABS::Page, type: :model do
  describe "#initialize" do
    subject(:page) { described_class.new(entry) }

    let(:entry) { page_entry }

    it "sets the attributes" do
      expect(page).to have_attributes(
        id: be_present,
        title: be_present,
        body: be_present,
        description: be_present,
        slug: be_present,
        related_content: be_present,
      )
    end
  end

  describe ".find_by_slug!" do
    subject(:page) { described_class.find_by_slug!(slug) }

    context "when page exists" do
      let(:slug) { "dynamic-purchasing-systems" }
      let(:entry) { page_entry(slug:) }

      before do
        allow(ContentfulClient).to receive(:entries).and_return([entry])
      end

      it "returns the page" do
        expect(page).to be_a(described_class)
        expect(page.slug).to eq(slug)
      end

      it "has related content" do
        expect(page.related_content).to be_present
      end
    end

    context "when page does not exist" do
      let(:slug) { "non-existent" }

      before do
        allow(ContentfulClient).to receive(:entries).and_return([])
      end

      it "raises ContentfulRecordNotFoundError" do
        expect { page }.to raise_error(ContentfulRecordNotFoundError, "Page not found")
      end
    end
  end

  def page_entry(id: "page-id", title: "Dynamic purchasing systems", body: "Page body", description: "Page description", slug: "dynamic-purchasing-systems", related_content: [related_content_entry], parent: nil)
    OpenStruct.new(
      id:,
      fields: {
        title:,
        body:,
        description:,
        slug:,
        related_content:,
        parent:,
      },
    )
  end

  def related_content_entry(id: "related-content-id", link_text: "Related content", url: "https://example.com/related")
    OpenStruct.new(
      id:,
      fields: {
        link_text:,
        url:,
      },
    )
  end
end
