RSpec.describe LiquidParser do
  describe "#render" do
    it "fills in given answers" do
      parser = described_class.new(
        template: 'Markdown paragraph rendering a variable: "{{ variable_name }}"',
        answers: {
          "variable_name" => "variable value",
        },
      )

      expect(parser.render).to eq "Markdown paragraph rendering a variable: \"variable value\""
    end
  end
end
