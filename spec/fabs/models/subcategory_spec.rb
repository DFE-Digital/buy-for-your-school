require "rails_helper"

RSpec.describe Subcategory, :vcr, type: :model do
  describe "#initialize" do
    subject(:subcategory) { described_class.new(entry) }

    let(:entry) do
      ContentfulClient.entries(
        content_type: "subcategory",
        "fields.slug": "software"
      ).first
    end

    it "sets the attributes" do
      expect(subcategory).to have_attributes(
        id: be_present,
        title: be_present,
        slug: be_present
      )
    end
  end
end
