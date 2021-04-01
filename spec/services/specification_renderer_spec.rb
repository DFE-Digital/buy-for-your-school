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

  describe "#to_document_html" do
    context "when the journey is complete" do
      it "renders HTML for use in rendering a docx file" do
        renderer = described_class.new(
          template: '<p>HTML paragraph rendering a variable: "{{ variable_name }}"</p>',
          answers: {
            "variable_name" => "variable value"
          }
        )
        expect(renderer.to_document_html(journey_complete: true))
          .to eql('<p>HTML paragraph rendering a variable: "variable value"</p>')
      end
    end

    context "when the journey is NOT complete" do
      it "renders HTML with an extra warning for use in rendering a docx file" do
        renderer = described_class.new(
          template: '<p>HTML paragraph rendering a variable: "{{ variable_name }}"</p>',
          answers: {
            "variable_name" => "variable value"
          }
        )
        warning_html = I18n.t("journey.specification.download.warning.incomplete")
        common_html = '<p>HTML paragraph rendering a variable: "variable value"</p>'
        expect(renderer.to_document_html(journey_complete: false))
          .to eql(warning_html + common_html)
      end
    end
  end
end
