require "rails_helper"

RSpec.describe Energy::ElectricityMeter, type: :model do
  let(:support_case) { create(:support_case) }
  let(:onboarding_case) { create(:onboarding_case, support_case:) }
  let(:onboarding_case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case:) }
  let(:electricity_meter) { create(:energy_electricity_meter, :with_valid_data, onboarding_case_organisation:) }

  it "updates the updated_at timestamp in Support::Case when ElectricityMeter is updated" do
    initial_timestamp = support_case.updated_at

    electricity_meter.update!(mpan: "1234567890123")

    support_case.reload

    expect(support_case.updated_at).to be > initial_timestamp
  end
end
