require "rails_helper"

RSpec.describe Offer, :vcr, type: :model do
  describe "#initialize" do
    subject(:offer) { described_class.new(entry) }

    let(:entry) do
      ContentfulClient.entries(
        content_type: "offer",
        "fields.slug": "energy-for-schools"
      ).first
    end

    it "sets the attributes" do
      expect(offer).to have_attributes(
        id: be_present,
        title: be_present,
        description: be_present,
        slug: be_present,
        url: be_present
      )
    end
  end

  describe ".all" do
    subject(:offers) { described_class.all }

    it "fetches offers from Contentful" do
      expect(offers).to be_present
      expect(offers).to be_a(Array)
      expect(offers).to all(be_a(described_class))
    end

    it "fetches offers ordered by sort_order" do
      expect(offers).to be_present
      # Verify offers are ordered by sort_order (ascending)
      sort_orders = offers.map(&:sort_order).compact
      expect(sort_orders).to eq(sort_orders.sort) if sort_orders.any?
    end
  end

  describe ".find_by_slug!" do
    subject(:offer) { described_class.find_by_slug!(slug) }

    context "when offer exists" do
      let(:slug) { "energy-for-schools" }

      it "returns the offer" do
        expect(offer).to be_a(described_class)
        expect(offer.slug).to eq(slug)
      end
    end

    context "when offer does not exist" do
      let(:slug) { "non-existent" }

      it "raises ContentfulRecordNotFoundError" do
        expect { offer }.to raise_error(ContentfulRecordNotFoundError, "Offer not found")
      end
    end
  end
end
