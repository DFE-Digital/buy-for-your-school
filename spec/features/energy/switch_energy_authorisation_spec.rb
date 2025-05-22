require "rails_helper"

describe "Switch energy authorisation", :js do
  let(:support_organisation) { create(:support_organisation, urn: 100_253) }
  let(:user) { create(:user, :many_supported_schools_and_groups) }
  let(:category) { create(:support_category, title: "DfE Energy for Schools service") }

  before do
    allow(Support::Category).to receive(:find_by).with(title: "DfE Energy for Schools service").and_return(category)
  end

  specify "Are you authorised to switch energy suppliers" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    visit school_type_energy_authorisation_path(id: support_organisation.urn, type: "single")

    expect(page).to have_text("Are you authorised to switch energy suppliers for these schools?")

    click_link "Continue"

    expect(page).to have_text("Are you switching electricity, gas or both?")

    kase = Support::Case.last
    expect(kase.first_name).to eq("first_name")
    expect(kase.last_name).to eq("last_name")
    expect(kase.email).to eq("test@test")
    expect(kase.source).to eq("energy_onboarding")
    expect(kase.support_level).to eq("L7")
    expect(kase.category_id).to eq(category.id)
    expect(kase.organisation).to eq(support_organisation)
    expect(kase.state).to eq("on_hold")

    interaction = Support::Interaction.last
    expect(interaction.case_id).to eq(kase.id)
    expect(interaction.body).to eq("DfE Energy support case created")

    onboarding_case = Energy::OnboardingCase.last
    expect(onboarding_case.are_you_authorised).to be true
    expect(onboarding_case.support_case).to eq(kase)

    onboarding_case_org = Energy::OnboardingCaseOrganisation.last
    expect(onboarding_case_org.onboarding_case).to eq(onboarding_case)
    expect(onboarding_case_org.onboardable).to eq(support_organisation)

    expect(Support::Case.count).to eq(1)
    visit school_type_energy_authorisation_path(id: support_organisation.urn, type: "single")
    expect(page).to have_current_path(energy_case_switch_energy_path(case_id: onboarding_case.id))

    onboarding_case_org.update!(switching_energy_type: "electricity")
    visit school_type_energy_authorisation_path(id: support_organisation.urn, type: "single")
    expect(page).to have_current_path(energy_case_tasks_path(case_id: onboarding_case.id))

    kase.update!(state: "closed")
    visit school_type_energy_authorisation_path(id: support_organisation.urn, type: "single")
    expect(page).to have_text("Are you authorised to switch energy suppliers for these schools?")
    click_link "Continue"
    expect(page).to have_text("Are you switching electricity, gas or both?")
    expect(Support::Case.count).to eq(2)
  end
end
