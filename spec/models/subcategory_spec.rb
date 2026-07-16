require "rails_helper"

RSpec.describe Subcategory, type: :model do
  describe "#initialize" do
    subject(:subcategory) { described_class.new(entry) }

    let(:entry) { subcategory_entry }

    it "sets the attributes" do
      expect(subcategory).to have_attributes(
        id: be_present,
        title: be_present,
        slug: be_present,
      )
    end
  end

  def subcategory_entry(id: "subcategory-id", title: "Software", slug: "software")
    OpenStruct.new(
      id:,
      fields: {
        title:,
        slug:,
      },
    )
  end
end
