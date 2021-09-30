require "rails_helper"

RSpec.describe LongTextAnswerPresenter do
  describe "#response" do
    it "returns the response in HTML using the Rails simple_format method" do
      step = build(:long_text_answer, response: "Lots of text")
      presenter = described_class.new(step)
      expect(presenter.response).to eq "Lots of text"
    end

    context "when the text includes line breaks" do
      it "returns 2 HTML paragraphs" do
        step = build(:long_text_answer, response: "First line\r\nSecond line")
        presenter = described_class.new(step)
        expect(presenter.response).to eq "First line\r\nSecond line"
      end
    end
  end

  describe "#to_param" do
    it "returns a hash of long_text_answer" do
      step = build(:long_text_answer, response: "First line\r\nSecond line")
      presenter = described_class.new(step)
      expect(presenter.to_param).to eql({ response: "First line\r\nSecond line" })
    end
  end
end
