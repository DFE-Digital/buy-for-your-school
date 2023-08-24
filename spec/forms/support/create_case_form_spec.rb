RSpec.describe Support::CreateCaseForm, type: :model do
  subject(:form) { described_class.new }

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
        request_type: "true",
        source: "sw_hub",
        procurement_amount: "10",
        upload_reference: "test-value",
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
        source: "sw_hub",
        procurement_amount: "10",
        file_attachments: [],
        upload_reference: "test-value",
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
