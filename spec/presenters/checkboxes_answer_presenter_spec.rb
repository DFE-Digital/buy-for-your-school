require "rails_helper"

RSpec.describe CheckboxesAnswerPresenter do
  describe "#response" do
    it "returns all none nil values as an array" do
      step = build(:checkbox_answers, response: ["Yes", "No", "Morning break", ""])
      presenter = described_class.new(step)
      expect(presenter.response).to eq(["Yes", "No", "Morning break"])
    end
  end
end
