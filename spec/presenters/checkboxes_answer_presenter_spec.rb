require "rails_helper"

RSpec.describe CheckboxesAnswerPresenter do
  describe "#response" do
    it "returns all none nil values, capitalised as a comma separated string" do
      step = build(:checkbox_answers, response: ["yes", "no", "morning break", ""])
      presenter = described_class.new(step)
      expect(presenter.response).to eq("Yes, No, Morning break")
    end
  end
end
