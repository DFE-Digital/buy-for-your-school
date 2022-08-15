RSpec.describe ExitSurvey::BetterQualityFormSchema do
  subject(:schema) { described_class.new.call(nil) }

  describe "validates better_quality" do
    context "when the better_quality key is provided" do
      context "and it is blank" do
        subject(:schema) { described_class.new.call(better_quality: "") }

        it "raises a validation error" do
          expect(schema.errors.messages.size).to eq 1
          expect(schema.errors.messages[0].to_s).to eq "Select whether you agree or disagree that using the service helped your school to buy better quality goods or services."
        end
      end

      context "and it is not blank" do
        subject(:schema) { described_class.new.call(better_quality: "agree") }

        it "does not raise a validation error" do
          expect(schema.errors.messages.size).to eq 0
        end
      end
    end

    context "when the better_quality key is not provided" do
      it "raises a validation error" do
        expect(schema.errors.messages.size).to eq 1
        expect(schema.errors.messages[0].to_s).to eq "is missing"
      end
    end
  end
end
