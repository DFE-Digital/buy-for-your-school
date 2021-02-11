require "rails_helper"

RSpec.describe CurrencyAnswerPresenter do
  describe "#response" do
    it "returns the response formatted as a currency" do
      step = build(:currency_answer, response: 1000.01)
      presenter = described_class.new(step)
      expect(presenter.response).to eq("£1,000.01")
    end
  end
end
