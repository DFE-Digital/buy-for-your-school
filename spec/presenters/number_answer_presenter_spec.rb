require "rails_helper"

RSpec.describe NumberAnswerPresenter do
  describe "#response" do
    it "returns the response" do
      step = build(:number_answer, response: 100)
      presenter = described_class.new(step)
      expect(presenter.response).to eq(100)
    end
  end
end
