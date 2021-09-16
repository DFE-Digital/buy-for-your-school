RSpec.describe DocumentFormatter do
  describe "#call" do
    it "converts Markdown into DOCX" do
      md = "# Title"
      formatter = described_class.new(content: md)

      expect(PandocRuby)
      .to receive(:convert)
      .with(md, { from: :markdown, to: :docx })
      .and_call_original

      formatter.call
    end

    it "converts Markdown into HTML" do
      md = "# Title"
      formatter = described_class.new(content: md, to: :html)

      expect(PandocRuby)
      .to receive(:convert)
      .with(md, { from: :markdown, to: :html })
      .and_call_original

      formatter.call
    end
  end
end
