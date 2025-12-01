RSpec.describe NewJourneyFormSchema do
  subject(:schema) { described_class.new.call(nil) }

  describe "validates category" do
    context "when the category key is provided" do
      context "and it is blank" do
        subject(:schema) { described_class.new.call(category: "") }

        it "raises a validation error" do
          expect(schema.errors.messages.size).to eq 1
          expect(schema.errors.messages[0].to_s).to eq "Select what you are buying"
        end
      end

      context "and it is not blank" do
        subject(:schema) { described_class.new.call(category: "catering") }

        it "does not raise a validation error" do
          expect(schema.errors.messages.size).to eq 0
        end
      end
    end

    context "when the category key is not provided" do
      it "does not raise a validation error" do
        expect(schema.errors.messages.size).to eq 0
      end
    end
  end

  describe "validates name" do
    context "when the name key is provided" do
      context "and it is blank" do
        subject(:schema) { described_class.new.call(name: "") }

        it "raises a validation error" do
          expect(schema.errors.messages.size).to eq 1
          expect(schema.errors.messages[0].to_s).to eq "Enter a name for your specification"
        end
      end

      context "and it is more than 30 characters" do
        subject(:schema) { described_class.new.call(name: "This is a very long specification name") }

        it "raises a validation error" do
          expect(schema.errors.messages.size).to eq 1
          expect(schema.errors.messages[0].to_s).to eq "The name must be 30 characters or less"
        end
      end

      context "and it is not blank" do
        subject(:schema) { described_class.new.call(name: "Test spec") }

        it "does not raise a validation error" do
          expect(schema.errors.messages.size).to eq 0
        end
      end
    end

    context "when the name key is not provided" do
      it "does not raise a validation error" do
        expect(schema.errors.messages.size).to eq 0
      end
    end
  end
end
