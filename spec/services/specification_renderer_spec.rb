require "rails_helper"

RSpec.describe SpecificationRenderer do
  describe "#to_html" do
    it "renders a HTML representation of a template given specific answers" do
      renderer = described_class.new(
        template: '<p>HTML paragraph rendering a variable: "{{ variable_name }}"</p>',
        answers: {
          "variable_name" => "variable value"
        }
      )
      expect(renderer.to_html).to eql('<p>HTML paragraph rendering a variable: "variable value"</p>')
    end
  end
end
