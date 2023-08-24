RSpec.describe Support::CreateCase do
  subject(:service) { described_class }

  let(:category) { create(:support_category, title: "Catering") }
  let(:organisation) { create(:support_organisation, name: "Hillside School") }
  let(:organisations) do
    [
      create(:support_organisation, name: "School 1"),
      create(:support_organisation, name: "School 2"),
    ]
  end

  before { create(:support_procurement_stage, title: "Need", key: "need") }

  # we may want to create a case and assign agent straight away - i.e. the agent filling in the migration form
  context "without an agent" do
    let(:case_params) do
      {
        category_id: category.id,
        organisation:,
        source: "sw_hub",
        first_name: "first_name",
        last_name: "last_name",
        email: "test@example.com",
        phone_number: "00000000000",
        extension_number: "2121",
        procurement_amount: 234.55,
        user_selected_category: "Catering sub-category",
        organisations:,
      }
    end

    it "creates a new case" do
      expect(Support::Case.count).to be 0

      result = service.new(case_params).call

      expect(result.category.title).to eq "Catering"
      expect(result.organisation.name).to eq "Hillside School"
      expect(result.source).to eq "sw_hub"
      expect(result.new_contract).not_to be_nil
      expect(result.existing_contract).not_to be_nil
      expect(result.procurement).not_to be_nil
      expect(result.extension_number).to eq "2121"
      expect(result.support_level).to eq "L1"
      expect(result.value).to eq 234.55
      expect(result.user_selected_category).to eq "Catering sub-category"
      expect(result.procurement_stage.title).to eq "Need"
      expect(result.organisations.pluck(:name)).to match_array(["School 1", "School 2"])
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
