# require "rails_helper"

RSpec.describe Energy::OnboardingCase, type: :model do
  # This may seem over the top but the relations during development where being
  # very trying.
  # Feel free to delete this down the road
  it "has working relations" do
    # Given existing support entities
    support_case = create(:support_case)
    support_organisation = create(:support_organisation)
    support_establishment_group = create(:support_establishment_group)

    # Create energy entities
    onboarding_case = described_class.create!(support_case:, are_you_authorised: true)
    oco1 = onboarding_case.onboarding_case_organisations.create!(switching_energy_type: 1, onboardable: support_organisation)
    oco2 = onboarding_case.onboarding_case_organisations.create!(switching_energy_type: 2, onboardable: support_establishment_group)

    # Check relations
    expect(support_case.energy_onboarding_case).to eq(onboarding_case)
    expect(onboarding_case.onboarding_case_organisations.count).to eq(2)
    expect(support_organisation.energy_onboarding_case_organisation).to eq(oco1)
    expect(support_establishment_group.energy_onboarding_case_organisation).to eq(oco2)
  end
end
