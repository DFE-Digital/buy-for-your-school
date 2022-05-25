RSpec.describe Support::CaseContractsFormSchema do
  subject(:schema) { described_class.new.call(**date_fields) }

  let(:date_values) do
    {
      "day" => nil,
      "month" => nil,
      "year" => nil,
    }
  end

  let(:date_fields) do
    {
      started_at: date_values,
      ended_at: date_values,
    }
  end

  describe "validates spend" do
    context "when the spend key is provided" do
      context "and it is blank" do
        subject(:schema) { described_class.new.call(spend: "", **date_fields) }

        it "does not raise a validation error" do
          expect(schema.errors.messages.size).to eq 0
        end
      end

      context "and it is a numeric string" do
        subject(:schema) { described_class.new.call(spend: "56000", **date_fields) }

        it "does not raise a validation error" do
          expect(schema.errors.messages.size).to eq 0
        end
      end

      context "and it is a non-numeric string" do
        subject(:schema) { described_class.new.call(spend: "ten", **date_fields) }

        it "raises a validation error" do
          expect(schema.errors.messages.size).to eq 1
          expect(schema.errors.messages[0].to_s).to eq "is invalid"
        end
      end
    end

    context "when the spend key is not provided" do
      it "does not raise a validation error" do
        expect(schema.errors.messages.size).to eq 0
      end
    end
  end
end
