require "rails_helper"

RSpec.describe Offer, type: :model do
  describe "#initialize" do
    subject(:offer) { described_class.new(entry) }

    let(:entry) { offer_entry }

    it "sets the attributes" do
      expect(offer).to have_attributes(
        id: be_present,
        title: be_present,
        description: be_present,
        slug: be_present,
        url: be_present,
      )
    end
  end

  describe ".all" do
    subject(:offers) { described_class.all }

    let(:entry_a) { offer_entry(id: "offer-a", title: "Alpha offer", slug: "alpha-offer", sort_order: 1) }
    let(:entry_b) { offer_entry(id: "offer-b", title: "Beta offer", slug: "beta-offer", sort_order: 2) }

    before do
      allow(ContentfulClient).to receive(:entries).and_return([entry_a, entry_b])
    end

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

  describe ".featured_offers" do
    subject(:offers) { described_class.featured_offers }

    let(:featured_entry_1) { offer_entry(id: "offer-1", title: "Alpha offer", slug: "alpha-offer", sort_order: 1, featured_on_homepage: true) }
    let(:featured_entry_2) { offer_entry(id: "offer-2", title: "Beta offer", slug: "beta-offer", sort_order: 2, featured_on_homepage: true) }
    let(:featured_entry_3) { offer_entry(id: "offer-3", title: "Gamma offer", slug: "gamma-offer", sort_order: 3, featured_on_homepage: true) }

    before do
      allow(ContentfulClient).to receive(:entries).and_return([featured_entry_1, featured_entry_2, featured_entry_3])
    end

    it "returns offers in correct order" do
      expect(offers).to have_attributes(length: 3)
      expect(offers.map(&:slug)).to eq(%w[alpha-offer beta-offer gamma-offer])
    end
  end

  describe ".find_by_slug!" do
    subject(:offer) { described_class.find_by_slug!(slug) }

    context "when offer exists" do
      let(:slug) { "energy-for-schools" }
      let(:entry) { offer_entry(slug:) }

      before do
        allow(ContentfulClient).to receive(:entries).and_return([entry])
      end

      it "returns the offer" do
        expect(offer).to be_a(described_class)
        expect(offer.slug).to eq(slug)
      end
    end

    context "when offer does not exist" do
      let(:slug) { "non-existent" }

      before do
        allow(ContentfulClient).to receive(:entries).and_return([])
      end

      it "raises ContentfulRecordNotFoundError" do
        expect { offer }.to raise_error(ContentfulRecordNotFoundError, "Offer not found")
      end
    end
  end

  def offer_entry(id: "offer-id", title: "Energy for schools", description: "Description", summary: "Summary", slug: "energy-for-schools", url: "https://example.com", call_to_action: "Call to action", image: nil, featured_on_homepage: false, expiry: nil, sort_order: 1, related_content: [])
    OpenStruct.new(
      id:,
      fields: {
        title:,
        description:,
        summary:,
        slug:,
        url:,
        call_to_action:,
        image:,
        featured_on_homepage:,
        expiry:,
        sort_order:,
        related_content:,
      },
    )
  end
end
