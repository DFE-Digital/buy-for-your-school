require "rails_helper"

describe Support::Markdown do
  describe "#to_html" do
    it "uses PandocRuby to convert markdown formatted text to html" do
      markdown_string = "Test String"
      output_html = "<p>Output HTML</p>"

      allow(PandocRuby).to receive(:convert)
        .with(markdown_string, "--strip-comments", from: :markdown, to: :html)
        .and_return(output_html)

      markdown = described_class.new(markdown_string)

      expect(markdown.to_html).to eq(output_html)
    end
  end
end
