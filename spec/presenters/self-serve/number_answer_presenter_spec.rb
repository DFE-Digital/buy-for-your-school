require "rails_helper"

RSpec.describe NumberAnswerPresenter do
  describe "#response" do
    it "returns the response as a string" do
      step = build(:number_answer, response: 100)
      presenter = described_class.new(step)
      expect(presenter.response).to eq("100")
    end
  end

  describe "#to_param" do
    it "returns a hash of number_answer" do
      step = build(:number_answer, response: 1)
      presenter = described_class.new(step)
      expect(presenter.to_param).to eql({ response: "1" })
    end
  end
end
