require "rails_helper"

RSpec.describe ShortTextAnswerPresenter do
  describe "#response" do
    it "returns the response" do
      step = build(:short_text_answer, response: "A little of text")
      presenter = described_class.new(step)
      expect(presenter.response).to eq("A little of text")
    end
  end
end
