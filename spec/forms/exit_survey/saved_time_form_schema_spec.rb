RSpec.describe ExitSurvey::SavedTimeFormSchema do
  subject(:schema) { described_class.new.call(nil) }

  describe "validates saved_time" do
    context "when the saved_time key is provided" do
      context "and it is blank" do
        subject(:schema) { described_class.new.call(saved_time: "") }

        it "raises a validation error" do
          expect(schema.errors.messages.size).to eq 1
          expect(schema.errors.messages[0].to_s).to eq "Select whether you agree or disagree that using the service helped save you or your school time."
        end
      end

      context "and it is not blank" do
        subject(:schema) { described_class.new.call(saved_time: "disagree") }

        it "does not raise a validation error" do
          expect(schema.errors.messages.size).to eq 0
        end
      end
    end

    context "when the saved_time key is not provided" do
      it "raises a validation error" do
        expect(schema.errors.messages.size).to eq 1
        expect(schema.errors.messages[0].to_s).to eq "is missing"
      end
    end
  end
end
