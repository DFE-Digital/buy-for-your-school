require "rails_helper"

RSpec.describe FABS::Page, :vcr, type: :model do
  describe "#initialize" do
    subject(:page) { described_class.new(entry) }

    let(:entry) do
      ContentfulClient.entries(
        content_type: "page",
        "fields.slug": "dynamic-purchasing-systems",
      ).first
    end

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

      it "raises ContentfulRecordNotFoundError" do
        expect { page }.to raise_error(ContentfulRecordNotFoundError, "Page not found")
      end
    end
  end
end
