RSpec.describe ExitSurvey::FutureSupportFormSchema do
  subject(:schema) { described_class.new.call(nil) }

  describe "validates future_support" do
    context "when the better_quality key is provided" do
      context "and it is blank" do
        subject(:schema) { described_class.new.call(future_support: "") }

        it "raises a validation error" do
          expect(schema.errors.messages.size).to eq 1
          expect(schema.errors.messages[0].to_s).to eq "Select whether you agree or disagree that you have learned enough to run the same type of proecurement in future with less support."
        end
      end

      context "and it is not blank" do
        subject(:schema) { described_class.new.call(future_support: "neither") }

        it "does not raise a validation error" do
          expect(schema.errors.messages.size).to eq 0
        end
      end
    end

    context "when the future_support key is not provided" do
      it "raises a validation error" do
        expect(schema.errors.messages.size).to eq 1
        expect(schema.errors.messages[0].to_s).to eq "is missing"
      end
    end
  end
end
