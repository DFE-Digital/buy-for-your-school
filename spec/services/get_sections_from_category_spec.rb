require "rails_helper"

RSpec.describe GetSectionsFromCategory do
  describe "#call" do
    it "returns an array of sections" do
      category = stub_contentful_category(
        fixture_filename: "radio-question.json",
        stub_steps: false
      )
      sections = stub_contentful_sections(category: category)

      result = described_class.new(category: category).call

      expect(result).to eq(sections)
    end
  end
end
