require "rails_helper"

RSpec.describe RadioAnswerPresenter do
  describe "#response" do
    it "returns the option chosen" do
      step = build(:radio_answer, response: "Yes", further_information: "Extra info")
      presenter = described_class.new(step)
      expect(presenter.response).to eq("Yes")
    end
  end
end
