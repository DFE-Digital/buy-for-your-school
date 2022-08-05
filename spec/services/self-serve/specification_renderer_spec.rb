RSpec.describe SpecificationRenderer do
  subject(:renderer) { described_class.new(journey:, draft_msg: "Draft message") }

  let(:journey) { build(:journey) }
  let(:liquid_parser_instance) { instance_double(LiquidParser) }
  let(:document_formatter_instance) { instance_double(DocumentFormatter) }

  describe "#call" do
    before do
      allow(LiquidParser).to receive(:new)
        .with(template: "Your answer was {{ answer_47EI2X2T5EDTpJX9WjRR9p }}", answers: {})
        .and_return(liquid_parser_instance)

      allow(liquid_parser_instance).to receive(:call)
        .and_return("Your answer was 4")
    end

    context "when the specification is a draft" do
      it "adds a draft warning" do
        allow(DocumentFormatter).to receive(:new)
          .with(content: "# category title specification: test spec\n\n\\\n\nDraft message\n\nYour answer was 4", from: :markdown, to: :docx)
          .and_return(document_formatter_instance)

        allow(document_formatter_instance).to receive(:call)

        renderer.call(draft: true)
      end
    end

    context "when the specification is not a draft" do
      it "does not modify the specification" do
        allow(DocumentFormatter).to receive(:new)
          .with(content: "# category title specification: test spec\n\n\\\n\nYour answer was 4", from: :markdown, to: :docx)
          .and_return(document_formatter_instance)

        allow(document_formatter_instance).to receive(:call)

        renderer.call(draft: false)
      end
    end
  end
end
