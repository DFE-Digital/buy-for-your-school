RSpec.feature "CEC homepage" do
  include_context "with a cec agent"

  let(:dfe_energy_category) { create(:support_category, title: "DfE Energy for Schools service") }
  let(:catering_cat) { create(:support_category, title: "Catering") }

  before do
    visit cec_root_path
  end

  it "is signed in as correct agent" do
    within ".govuk-header__container" do
      expect(page).to have_text "Signed in as Procurement Specialist"
    end
  end

  it "defaults to the 'my cases' tab" do
    expect(find("#my-cases")).not_to have_css ".govuk-tabs__panel--hidden"
  end

  context "when my cases tab" do
    before do
      create(:support_case, category: dfe_energy_category, state: :opened, agent:)
      create(:support_case, category: dfe_energy_category, state: :on_hold, agent: nil)
      visit "/cec/onboarding_cases"
    end

    it "shows my cases" do
      within "#my-cases" do
        expect(page).to have_text("Procurement Specialist")
        expect(page).not_to have_text("UNASSIGNED")
      end
    end
  end

  context "when all cases tab" do
    before do
      create(:support_case, category: dfe_energy_category, state: :opened, agent:)
      create(:support_case, category: catering_cat, agent: nil)
      visit "/cec/onboarding_cases"
    end

    it "shows all valid cases with the sub-category dfe energy for schools service" do
      within "#all-cases" do
        expect(page).to have_text("DfE Energy for Schools service")
        expect(page).not_to have_text("Catering")
      end
    end
  end
end
