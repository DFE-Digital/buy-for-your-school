require "rails_helper"

RSpec.describe Energy::OnboardingCaseOrganisation, type: :model do
  let(:support_case) { create(:support_case) }
  let(:onboarding_case) { create(:onboarding_case, support_case:) }
  let(:onboarding_case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case:) }

  describe "enums" do
    it "defines gas_current_supplier enum with correct values" do
      expect(described_class.gas_current_suppliers).to eq(
        "british_gas" => 0,
        "edf_energy" => 1,
        "eon_next" => 2,
        "scottish_power" => 3,
        "ovo_energy" => 4,
        "octopus_energy" => 5,
        "other" => 6,
      )
    end

    it "defines electric_current_supplier enum with correct values" do
      expect(described_class.electric_current_suppliers).to eq(
        "british_gas" => 0,
        "edf_energy" => 1,
        "eon_next" => 2,
        "scottish_power" => 3,
        "ovo_energy" => 4,
        "octopus_energy" => 5,
        "other" => 6,
      )
    end
  end

  it "updates the updated_at timestamp in Support::Case when OnboardingCaseOrganisation is updated" do
    initial_timestamp = support_case.updated_at

    onboarding_case_organisation.update!(switching_energy_type: :gas_electricity)

    support_case.reload

    expect(support_case.updated_at).to be > initial_timestamp

    updated_timestamp_1 = support_case.updated_at

    onboarding_case_organisation.update!(gas_current_supplier: :british_gas)

    support_case.reload

    expect(support_case.updated_at).to be > updated_timestamp_1
  end
end
