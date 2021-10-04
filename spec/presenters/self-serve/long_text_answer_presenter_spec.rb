RSpec.describe LongTextAnswerPresenter do
  let(:presenter) { described_class.new(step) }
  let(:step) { build(:long_text_answer, response: "First line\r\nSecond line") }

  describe "#to_param" do
    it "returns a hash of long_text_answer" do
      expect(presenter.to_param).to eql({ response: "First line\r\nSecond line" })
    end
  end
end
