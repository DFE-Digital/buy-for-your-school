require "rails_helper"

RSpec.describe CurrencyAnswerPresenter do
  describe "#response" do
    it "returns the response formatted as a currency" do
      step = build(:currency_answer, response: 1000.01)
      presenter = described_class.new(step)
      expect(presenter.response).to eq("£1,000.01")
    end
  end

  describe "#to_param" do
    it "returns a hash of currency_answer" do
      step = build(:currency_answer, response: 100.00)
      presenter = described_class.new(step)
      expect(presenter.to_param).to eql({ response: "£100.00" })
    end
  end
end
