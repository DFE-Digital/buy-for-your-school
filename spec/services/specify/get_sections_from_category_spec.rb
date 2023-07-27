require "rails_helper"

RSpec.describe GetSectionsFromCategory do
  describe "#call" do
    it "returns an array of sections" do
      category = stub_contentful_category(
        fixture_filename: "radio-question.json",
      )

      result = described_class.new(category:).call

      expect(result).to eq(category.sections)
    end
  end
end
