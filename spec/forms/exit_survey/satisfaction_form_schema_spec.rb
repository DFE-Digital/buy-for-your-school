RSpec.describe ExitSurvey::SatisfactionFormSchema do
  subject(:schema) { described_class.new.call(nil) }

  describe "validates satisfaction_level" do
    context "when the satisfaction_level key is provided" do
      context "and it is blank" do
        subject(:schema) { described_class.new.call(satisfaction_level: "") }

        it "raises a validation error" do
          expect(schema.errors.messages.size).to eq 1
          expect(schema.errors.messages[0].to_s).to eq "Select how you feel about the service you received."
        end
      end

      context "and it is not blank" do
        subject(:schema) { described_class.new.call(satisfaction_level: "satisfied") }

        it "does not raise a validation error" do
          expect(schema.errors.messages.size).to eq 0
        end
      end
    end

    context "when the satisfaction_level key is not provided" do
      it "raises a validation error" do
        expect(schema.errors.messages.size).to eq 1
        expect(schema.errors.messages[0].to_s).to eq "is missing"
      end
    end
  end
end
