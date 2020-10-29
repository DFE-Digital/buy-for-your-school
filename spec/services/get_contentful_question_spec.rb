require "rails_helper"

RSpec.describe GetContentfulQuestion do
  describe "#call" do
    it "returns the contents of Contentful fixture (for now)" do
      raw_response = File.read("#{Rails.root}/spec/fixtures/contentful/radio-question-example.json")
      fake_contentful_question_response = JSON.parse(raw_response)

      result = described_class.new.call

      expect(result).to eq(fake_contentful_question_response)
    end
  end
end
