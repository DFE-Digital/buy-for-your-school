RSpec.describe DocumentFormatter do
  describe "#call" do
    it "converts Markdown into DOCX" do
      md = "# Title"
      formatter = described_class.new(content: md, from: :markdown, to: :docx)

      expect(PandocRuby)
      .to receive(:convert)
      .with(md, "--strip-comments", { from: :markdown, to: :docx })
      .and_call_original

      formatter.call
    end

    it "converts Markdown into HTML" do
      md = "# Title"
      formatter = described_class.new(content: md, from: :markdown, to: :html)

      expect(PandocRuby)
      .to receive(:convert)
      .with(md, "--strip-comments", { from: :markdown, to: :html })
      .and_call_original

      html = formatter.call
      expect(html).to eq "<h1 id=\"title\">Title</h1>\n"
    end

    it "converts Markdown into PDF" do
      md = "# Title"
      pdf = "%PDF-1.4"
      formatter = described_class.new(content: md, from: :markdown, to: :pdf)

      allow(PandocRuby)
        .to receive(:convert)
        .with(md, "--strip-comments", { from: :markdown, to: :pdf })
        .and_return(pdf)

      expect(formatter.call).to eq(pdf)
    end
  end
end
