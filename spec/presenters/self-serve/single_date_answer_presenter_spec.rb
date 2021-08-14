require "rails_helper"

RSpec.describe SingleDateAnswerPresenter do
  describe "#response" do
    it "returns the response formatted as a date" do
      step = build(:single_date_answer, response: Date.new(2000, 12, 30))
      presenter = described_class.new(step)
      expect(presenter.response).to eq("30 Dec 2000")
    end
  end

  describe "#to_param" do
    it "returns a hash of single_date_answer" do
      step = build(:single_date_answer, response: Date.new(2000, 12, 30))
      presenter = described_class.new(step)
      expect(presenter.to_param).to eql({ response: "30 Dec 2000" })
    end
  end
end
