RSpec.describe ExitSurvey::OptInDetailFormSchema do
  subject(:schema) { described_class.new.call(nil) }

  describe "validates opt_in_name" do
    context "when the opt_in_name key is provided" do
      context "and it is blank" do
        subject(:schema) { described_class.new.call(opt_in_name: "", opt_in_email: "email@school.co.uk") }

        it "raises a validation error" do
          expect(schema.errors.messages.size).to eq 1
          expect(schema.errors.messages[0].to_s).to eq "Enter your full name."
        end
      end

      context "and it is not blank" do
        subject(:schema) { described_class.new.call(opt_in_name: "name", opt_in_email: "email@school.co.uk") }

        it "does not raise a validation error" do
          expect(schema.errors.messages.size).to eq 0
        end
      end
    end

    context "when the opt_in_name key is not provided" do
      subject(:schema) { described_class.new.call(opt_in_email: "email@school.co.uk") }

      it "raises a validation error" do
        expect(schema.errors.messages.size).to eq 1
        expect(schema.errors.messages[0].to_s).to eq "is missing"
      end
    end
  end

  describe "validates opt_in_email" do
    context "when the opt_in_email key is provided" do
      context "and it is blank" do
        subject(:schema) { described_class.new.call(opt_in_email: "", opt_in_name: "name") }

        it "raises a validation error" do
          expect(schema.errors.messages.size).to eq 1
          expect(schema.errors.messages[0].to_s).to eq "Enter an email address. For example, 'someone@school.sch.uk'."
        end
      end

      context "and it is not blank" do
        context "and it is a valid email address" do
          subject(:schema) { described_class.new.call(opt_in_email: "email@school.co.uk", opt_in_name: "name") }

          it "does not raise a validation error" do
            expect(schema.errors.messages.size).to eq 0
          end
        end

        context "and it is an invalid email address" do
          subject(:schema) { described_class.new.call(opt_in_email: "email99", opt_in_name: "name") }

          it "raises a validation error" do
            expect(schema.errors.messages.size).to eq 1
            expect(schema.errors.messages[0].to_s).to eq "Enter a valid email address. For example, 'someone@school.sch.uk'."
          end
        end
      end
    end

    context "when the opt_in_email key is not provided" do
      subject(:schema) { described_class.new.call(opt_in_name: "name") }

      it "raises a validation error" do
        expect(schema.errors.messages.size).to eq 1
        expect(schema.errors.messages[0].to_s).to eq "is missing"
      end
    end
  end
end
