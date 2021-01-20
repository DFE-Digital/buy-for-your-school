require "rails_helper"

RSpec.describe LongTextAnswerPresenter do
  describe "#response" do
    it "returns the response in HTML using the Rails simple_format method" do
      step = build(:long_text_answer, response: "Lots of text")
      presenter = described_class.new(step)
      expect(presenter.response).to eq("<p>Lots of text</p>")
    end

    context "when the text includes line breaks" do
      it "returns 2 HTML paragraphs" do
        step = build(:long_text_answer, response: "First line\r\nSecond line")
        presenter = described_class.new(step)
        expect(presenter.response).to eq("<p>First line\n<br />Second line</p>")
      end
    end
  end
end
