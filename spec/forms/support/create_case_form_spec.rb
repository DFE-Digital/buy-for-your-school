RSpec.describe Support::CreateCaseForm, type: :model do
  subject(:form) { described_class.new }

  describe "#case_type" do
    context "when there is no hub case reference" do
      it "is nil" do
        expect(form.case_type).to be_nil
      end
    end

    context "when hub case reference is an integer in range 1000-99_999" do
      subject(:form) { described_class.new(hub_case_ref: "5400") }

      it "is nw_hub" do
        expect(form.case_type).to eq "nw_hub"
      end
    end

    context "when hub case reference is prefixed with 'ce-'" do
      subject(:form) { described_class.new(hub_case_ref: "CE-553") }

      it "is sw_hub" do
        expect(form.case_type).to eq "sw_hub"
      end
    end
  end

  describe "#to_h" do
    subject(:form) do
      described_class.new(
        organisation_id: "123",
        organisation_type: "school",
        organisation_name: "Test School",
        organisation_urn: "321",
        first_name: "Test",
        last_name: "User",
        email: "test@test.com",
        phone_number: "5554321",
        category_id: "987",
        hub_case_ref: "CE-553",
        estimated_procurement_completion_date: "2022-01-01",
        estimated_savings: "25000",
        hub_notes: "note",
        progress_notes: "progress",
        request_type: "true",
      )
    end

    it "returns form values" do
      expect(form.to_h).to eql({
        organisation_id: "123",
        organisation_type: "school",
        organisation_name: "Test School",
        organisation_urn: "321",
        first_name: "Test",
        last_name: "User",
        email: "test@test.com",
        phone_number: "5554321",
        category_id: "987",
        hub_case_ref: "CE-553",
        estimated_procurement_completion_date: "2022-01-01",
        estimated_savings: "25000",
        hub_notes: "note",
        progress_notes: "progress",
        source: "sw_hub",
      })
    end
  end

  describe "#request_type?" do
    it "returns field value" do
      form = described_class.new(request_type: "true")
      expect(form.request_type?).to eq true
      form = described_class.new(request_type: "false")
      expect(form.request_type?).to eq false
    end
  end
end
