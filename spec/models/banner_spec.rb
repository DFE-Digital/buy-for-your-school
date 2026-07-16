require "rails_helper"

RSpec.describe Banner, type: :model do
  let(:energy_slug) { "energy-for-schools" }

  describe "#initialize" do
    subject(:banner) { described_class.new(entry) }

    let(:entry) { banner_entry(slug: energy_slug) }

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
      allow(ContentfulClient).to receive(:entries).and_return([banner_entry(slug: energy_slug)])

      banner = described_class.find_by_slug(energy_slug)
      expect(banner).to be_present
      expect(banner).to be_a(described_class)
      expect(banner.slug).to eq(energy_slug)
    end

    it "returns nil if no banner is found by the given slug" do
      allow(ContentfulClient).to receive(:entries).and_return([])

      banner = described_class.find_by_slug("non-existent-slug")
      expect(banner).to be_nil
    end
  end

  def banner_entry(id: "banner-id", title: "Energy for schools", description: "Banner description", call_to_action: "View energy", url: "https://example.com", slug: "energy-for-schools", image: "image.png")
    OpenStruct.new(
      id:,
      fields: {
        title:,
        description:,
        call_to_action:,
        url:,
        slug:,
        image:,
      },
    )
  end
end
