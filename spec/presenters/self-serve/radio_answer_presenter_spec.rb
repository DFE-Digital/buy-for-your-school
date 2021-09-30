require "rails_helper"

RSpec.describe RadioAnswerPresenter do
  describe "#response" do
    it "returns the option chosen" do
      step = build(:radio_answer,
                   response: "Yes",
                   further_information: { yes_further_information: "More yes info" })
      presenter = described_class.new(step)
      expect(presenter.response).to eq("Yes")
    end
  end

  describe "#to_param" do
    it "returns a hash of radio_answer" do
      step = build(:radio_answer,
                   response: "Yes",
                   further_information: { yes_further_information: "More yes info" })

      presenter = described_class.new(step)

      expect(presenter.to_param).to eql({
        response: "Yes",
        further_information: "More yes info",
      })
    end
  end
end
