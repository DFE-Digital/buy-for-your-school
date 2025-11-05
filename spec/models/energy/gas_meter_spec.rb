require "rails_helper"

RSpec.describe Energy::GasMeter, type: :model do
  let(:support_case) { create(:support_case) }
  let(:onboarding_case) { create(:onboarding_case, support_case:) }
  let(:onboarding_case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case:) }
  let(:gas_meter) { create(:energy_gas_meter, :with_valid_data, onboarding_case_organisation:) }

  it "updates the updated_at timestamp in Support::Case when GasMeter is updated" do
    initial_timestamp = support_case.updated_at

    gas_meter.update!(mprn: "5555555555")

    support_case.reload

    expect(support_case.updated_at).to be > initial_timestamp
  end
end
