RSpec.describe RequestFormSchema do
  subject(:schema) { described_class.new.call(nil) }

  describe "validates procurement_choice" do
    context "when the procurement_choice key is provided" do
      context "and it is blank" do
        subject(:schema) { described_class.new.call(procurement_choice: "") }

        it "raises a validation error" do
          expect(schema.errors.messages.size).to eq 1
          expect(schema.errors.messages[0].to_s).to eq "Select whether you know how much is being spent"
        end
      end

      context "and it is not blank" do
        subject(:schema) { described_class.new.call(procurement_choice: "yes") }

        it "does not raise a validation error" do
          expect(schema.errors.messages.size).to eq 0
        end
      end
    end

    context "when the procurement_choice key is not provided" do
      it "does not raise a validation error" do
        expect(schema.errors.messages.size).to eq 0
      end
    end
  end

  describe "validates procurement_amount" do
    # update
    context "when the procurement_amount key is provided" do
      context "and it is blank while the procurement_choice is yes" do
        subject(:schema) { described_class.new.call(procurement_amount: "", procurement_choice: "yes") }

        it "raises a validation error" do
          expect(schema.errors.messages.size).to eq 1
          expect(schema.errors.messages[0].to_s).to eq "Enter the approximate amount that will be spent"
        end
      end

      context "and it is non-numeric while the procurement_choice is yes" do
        subject(:schema) { described_class.new.call(procurement_amount: "abc", procurement_choice: "yes") }

        it "raises a validation error" do
          expect(schema.errors.messages.size).to eq 1
          expect(schema.errors.messages[0].to_s).to eq "Enter a number"
        end
      end

      context "and it is greater than 9,999,999.99 while the procurement_choice is yes" do
        subject(:schema) { described_class.new.call(procurement_amount: "10000000.00", procurement_choice: "yes") }

        it "raises a validation error" do
          expect(schema.errors.messages.size).to eq 1
          expect(schema.errors.messages[0].to_s).to eq "The amount cannot be larger than 9,999,999.99"
        end
      end

      context "and it is valid while the procurement_choice is yes" do
        subject(:schema) { described_class.new.call(procurement_amount: "45.21", procurement_choice: "yes") }

        it "does not raise a validation error" do
          expect(schema.errors.messages.size).to eq 0
        end
      end
    end

    context "when the procurement_amount key is not provided" do
      it "does not raise a validation error" do
        expect(schema.errors.messages.size).to eq 0
      end
    end
  end

  describe "validates confidence_level" do
    context "when the confidence_level key is provided" do
      context "and it is blank while the procurement_choice is not not_about_procurement, and we've not gone back in the form" do
        subject(:schema) { described_class.new.call(confidence_level: "", procurement_choice: "yes", back: false) }

        it "raises a validation error" do
          expect(schema.errors.messages.size).to eq 1
          expect(schema.errors.messages[0].to_s).to eq "Select how confident you feel about running this procurement"
        end
      end

      context "and it is not blank while the procurement_choice is not not_about_procurement, and we've not gone back in the form" do
        subject(:schema) { described_class.new.call(confidence_level: "confident", procurement_choice: "yes", back: false) }

        it "does not raise a validation error" do
          expect(schema.errors.messages.size).to eq 0
        end
      end
    end

    context "when the confidence_level key is not provided" do
      it "does not raise a validation error" do
        expect(schema.errors.messages.size).to eq 0
      end
    end
  end

  describe "validates special_requirements_choice" do
    context "when the special_requirements_choice key is provided" do
      context "and it is blank" do
        subject(:schema) { described_class.new.call(special_requirements_choice: "") }

        it "raises a validation error" do
          expect(schema.errors.messages.size).to eq 1
          expect(schema.errors.messages[0].to_s).to eq "Select whether you want to tell us about any special requirements"
        end
      end

      context "and it is not blank" do
        subject(:schema) { described_class.new.call(special_requirements_choice: "yes") }

        it "does not raise a validation error" do
          expect(schema.errors.messages.size).to eq 0
        end
      end
    end

    context "when the special_requirements_choice key is not provided" do
      it "does not raise a validation error" do
        expect(schema.errors.messages.size).to eq 0
      end
    end
  end

  describe "validates special_requirements" do
    context "when the special_requirements key is provided" do
      context "and it is blank while the special_requirements_choice is yes" do
        subject(:schema) { described_class.new.call(special_requirements: "", special_requirements_choice: "yes") }

        it "raises a validation error" do
          expect(schema.errors.messages.size).to eq 1
          expect(schema.errors.messages[0].to_s).to eq "Enter what your requirements are"
        end
      end

      context "and it is not blank while the special_requirements_choice is yes" do
        subject(:schema) { described_class.new.call(special_requirements: "reqs", special_requirements_choice: "yes") }

        it "does not raise a validation error" do
          expect(schema.errors.messages.size).to eq 0
        end
      end
    end

    context "when the special_requirements key is not provided" do
      it "does not raise a validation error" do
        expect(schema.errors.messages.size).to eq 0
      end
    end
  end
end
