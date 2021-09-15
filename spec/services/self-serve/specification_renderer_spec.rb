RSpec.describe SpecificationRenderer do
  describe "#markdown" do
    it "renders a Markdown representation of a template given specific answers" do
      renderer = described_class.new(
        template: 'Markdown paragraph rendering a variable: "{{ variable_name }}"',
        answers: {
          "variable_name" => "variable value",
        },
      )
      expect(renderer.markdown).to eq "Markdown paragraph rendering a variable: \"variable value\""
    end
  end

  describe "#html" do
    it "renders a HTML representation of a template given specific answers" do
      renderer = described_class.new(
        template: 'Markdown paragraph rendering a variable: "{{ variable_name }}"',
        answers: {
          "variable_name" => "variable value",
        },
      )
      expect(renderer.html).to eq "<p>Markdown paragraph rendering a variable: “variable value”</p>\n"
    end
  end
end
