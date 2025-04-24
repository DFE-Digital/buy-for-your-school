# require "rails_helper"

RSpec.describe Energy::OnboardingCase, type: :model do
  # This may seem over the top but the relations during development where being
  # very trying.
  # Feel free to delete this down the road
  it "has working relations" do
    support_case = create(:support_case)
    expect(support_case).to be_persisted

    oc = described_class.create!(support_case:, are_you_authorised: true)
    expect(support_case.energy_onboarding_case).to eq(oc)

    oco = oc.onboarding_case_organisations.create!(switching_energy_type: 1)
    expect(oco).to be_persisted
    expect(oco.onboarding_case).to eq(oc)

    support_case_organisation = create(:support_case_organisation)
    expect(support_case_organisation).to be_persisted

    oco.support_case_organisation = support_case_organisation
    oco.save!
    expect(oco.support_case_organisation).to eq(support_case_organisation)
    expect(support_case_organisation.energy_onboarding_case_organisation).to eq(oco)

    support_organisation = create(:support_organisation)
    expect(support_organisation).to be_persisted

    oco.support_organisation = support_organisation
    oco.save!
    expect(oco.support_organisation).to eq(support_organisation)
    expect(support_organisation.energy_onboarding_case_organisation).to eq(oco)

    support_establishment_group = create(:support_establishment_group)
    expect(support_establishment_group).to be_persisted

    oco.support_establishment_group = support_establishment_group
    oco.save!
    expect(oco.support_establishment_group).to eq(support_establishment_group)
    expect(support_establishment_group.energy_onboarding_case_organisation).to eq(oco)

    elec_meter = oco.electricity_meters.create!(mpan: "12345")
    expect(oco.electricity_meters).to eq([elec_meter])
    expect(elec_meter.onboarding_case_organisation).to eq(oco)
  end
end
