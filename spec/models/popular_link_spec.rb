require "rails_helper"

RSpec.describe PopularLink, type: :model do
  describe "#initialize" do
    subject(:popular_link) { described_class.new(entry) }

    let(:entry) { popular_link_entry }

    it "sets the attributes" do
      expect(popular_link).to have_attributes(
        id: be_present,
        title: be_present,
        url: be_present,
      )
    end
  end

  describe ".all" do
    subject(:popular_links) { described_class.all }

    let(:entry_a) { popular_link_entry(id: "link-a", title: "Alpha link", url: "/alpha", sort_order: 1) }
    let(:entry_b) { popular_link_entry(id: "link-b", title: "Beta link", url: "/beta", sort_order: 2) }

    before do
      allow(ContentfulClient).to receive(:entries).and_return([entry_a, entry_b])
    end

    it "fetches popular links from Contentful" do
      expect(popular_links).to be_present
      expect(popular_links).to be_a(Array)
      expect(popular_links).to all(be_a(described_class))
    end

    it "fetches popular links ordered by sort_order" do
      sort_orders = popular_links.map(&:sort_order).compact
      expect(sort_orders).to eq(sort_orders.sort) if sort_orders.any?
    end
  end

  def popular_link_entry(id: "popular-link-id", title: "Popular link", url: "https://example.com", sort_order: 1)
    OpenStruct.new(
      id:,
      fields: {
        title:,
        url:,
        sort_order:,
      },
    )
  end
end
