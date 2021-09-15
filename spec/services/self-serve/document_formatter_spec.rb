RSpec.describe DocumentFormatter do
  describe "#call" do
    context "when the journey is complete" do
      it "converts Markdown into DOCX" do
        md = "# Title"
        formatter = described_class.new(markdown: md)

        expect(PandocRuby)
        .to receive(:convert)
        .with(md, { from: :markdown, to: :docx })
        .and_call_original

        formatter.call(draft: false)
      end
    end

    context "when the journey is incomplete" do
      it "converts Markdown into DOCX with added warning" do
        md = "# Title"
        modified_md = "<article id='warning'><p></b>You have not completed all the tasks in Create a specification. There may be information missing from your specification.</b></p></article># Title"
        formatter = described_class.new(markdown: md)

        expect(PandocRuby)
        .to receive(:convert)
        .with(modified_md, { from: :markdown, to: :docx })
        .and_call_original

        formatter.call(draft: true)
      end
    end
  end
end
