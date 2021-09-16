RSpec.describe LiquidParser do
  describe "#render" do
    context "when the template is a draft" do
      it "fills in given answers with a draft warning" do
        parser = described_class.new(
          template: 'Markdown paragraph rendering a variable: "{{ variable_name }}"',
          answers: {
            "variable_name" => "variable value",
          },
          draft_msg: "Draft message",
        )

        expect(parser.render(draft: true)).to eq "Draft message\n\nMarkdown paragraph rendering a variable: \"variable value\""
      end
    end

    context "when the template is not a draft" do
      it "fills in given answers" do
        parser = described_class.new(
          template: 'Markdown paragraph rendering a variable: "{{ variable_name }}"',
          answers: {
            "variable_name" => "variable value",
          },
        )

        expect(parser.render(draft: false)).to eq "Markdown paragraph rendering a variable: \"variable value\""
      end
    end
  end
end
