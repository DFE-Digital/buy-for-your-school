require "rails_helper"

RSpec.describe Banner, :vcr, type: :model do
  describe "#initialize" do
    subject(:banner) { described_class.new(entry) }

    let(:entry) do
      ContentfulClient.entries(
        content_type: "banner",
        "fields.slug": "energy-for-schools",
      ).first
    end

    it "sets the attributes" do
      expect(banner).to have_attributes(
        id: be_present,
        title: be_present,
        description: be_present,
        call_to_action: be_present,
        url: be_present,
        slug: be_present,
        image: be_present,
      )
    end
  end

  describe ".find_by_slug" do
    it "fetches a banner by its slug from Contentful" do
      banner = described_class.find_by_slug("energy-for-schools")
      expect(banner).to be_present
      expect(banner).to be_a(described_class)
      expect(banner.slug).to eq("energy-for-schools")
    end

    it "returns nil if no banner is found by the given slug" do
      banner = described_class.find_by_slug("non-existent-slug")
      expect(banner).to be_nil
    end
  end
end
