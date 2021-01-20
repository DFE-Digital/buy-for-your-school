require "rails_helper"

RSpec.describe RadioAnswerPresenter do
  describe "#response" do
    it "returns the option chosen" do
      step = build(:radio_answer, response: "Yes", further_information: "")
      presenter = described_class.new(step)
      expect(presenter.response).to eq("Yes")
    end

    context "when further information is provided" do
      it "returns the option chosen and the further information" do
        step = build(:radio_answer, response: "Yes", further_information: "This is really important")
        presenter = described_class.new(step)
        expect(presenter.response).to eq("Yes - This is really important")
      end
    end
  end
end
