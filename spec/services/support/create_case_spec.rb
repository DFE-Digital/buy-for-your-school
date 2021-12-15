RSpec.describe Support::CreateCase do
  subject(:service) do
    described_class
  end

  let(:category) { create(:support_category, title: "Catering") }
  let(:organisation) { create(:support_organisation, name: "Hillside School") }

  # we may want to create a case and assign agent straight away - i.e. the agent filling in the migration form
  context "without an agent" do
    let(:case_params) do
      {
        category_id: category.id,
        organisation_id: organisation.id,
        source: "sw_hub",
        first_name: "first_name",
        last_name: "last_name",
        email: "test@example.com",
        phone_number: "00000000000",
      }
    end

    it "creates a new case" do
      expect(Support::Case.count).to be 0

      result = service.new(case_params).call

      expect(result.category.title).to eq "Catering"
      expect(result.organisation.name).to eq "Hillside School"
      expect(result.source).to eq "sw_hub"
      expect(Support::Case.count).to be 1
    end

    it "logs the create_case activity" do
      support_case = create(:support_case)
      allow(Support::Case).to receive(:create!)
        .and_return(support_case)

      record_action = instance_double("Support::RecordAction", call: nil)
      allow(Support::RecordAction).to receive(:new)
        .with(case_id: support_case.id, action: "create_case")
        .and_return(record_action)

      service.new(case_params).call

      expect(record_action).to have_received(:call)
    end
  end
end
