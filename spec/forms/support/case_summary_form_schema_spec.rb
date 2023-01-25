RSpec.describe Support::CaseSummaryFormSchema do
  subject(:schema) { described_class.new.call(**values) }

  let(:values) do
    { source: }
  end

  describe "validates source" do
    context "when the source value is provided" do
      let(:source) { "incoming_email" }

      it "does not raise a validation error" do
        expect(schema.errors.messages.size).to eq 0
      end
    end

    context "when the source value is not provided" do
      let(:source) { nil }

      it "raises a validation error" do
        expect(schema.errors.messages.size).to eq 1
        expect(schema.errors.messages[0].to_s).to eq "Select the source of the case"
      end
    end
  end
end
