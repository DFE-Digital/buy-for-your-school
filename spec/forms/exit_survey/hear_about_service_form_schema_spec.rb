RSpec.describe ExitSurvey::HearAboutServiceFormSchema do
  subject(:schema) { described_class.new.call(nil) }

  describe "validates hear_about_service" do
    context "when the hear_about_service key is provided" do
      context "and it is blank" do
        subject(:schema) { described_class.new.call(hear_about_service: "") }

        it "raises a validation error" do
          expect(schema.errors.messages.size).to eq 1
          expect(schema.errors.messages[0].to_s).to eq "Select how you heard about the service."
        end
      end

      context "and it is not blank" do
        subject(:schema) { described_class.new.call(hear_about_service: "dfe_event") }

        it "does not raise a validation error" do
          expect(schema.errors.messages.size).to eq 0
        end
      end
    end

    context "when the hear_about_service key is not provided" do
      it "raises a validation error" do
        expect(schema.errors.messages.size).to eq 1
        expect(schema.errors.messages[0].to_s).to eq "is missing"
      end
    end
  end

  describe "validates hear_about_service_other" do
    context "when the hear_about_service_other key is provided" do
      context "and it is blank" do
        context "and hear_about_service is set to other" do
          subject(:schema) { described_class.new.call(hear_about_service_other: "", hear_about_service: "other") }

          it "raises a validation error" do
            expect(schema.errors.messages.size).to eq 1
            expect(schema.errors.messages[0].to_s).to eq "Enter how you heard about the service."
          end
        end

        context "and hear_about_service is not set to other" do
          subject(:schema) { described_class.new.call(hear_about_service_other: "", hear_about_service: "dfe_event") }

          it "does not raise a validation error" do
            expect(schema.errors.messages.size).to eq 0
          end
        end
      end
    end

    context "when the hear_about_service_other key is not provided" do
      it "raises a validation error" do
        expect(schema.errors.messages.size).to eq 1
        expect(schema.errors.messages[0].to_s).to eq "is missing"
      end
    end
  end
end
