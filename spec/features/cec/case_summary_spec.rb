RSpec.feature "Case summary details" do
  include_context "with a cec agent"

  before do
    visit cec_onboarding_case_path(support_case)
    click_on "Case details"
  end

  context "when the case is an energy for schools case" do
    let(:dfe_energy_category) { create(:support_category, title: "DfE Energy for Schools service") }
    let(:energy_stage) { create(:support_procurement_stage, key: "onboarding_form", title: "Onboarding form", stage: "6") }
    let(:support_case) { create(:support_case, category: dfe_energy_category, support_level: "L7", source: :energy_onboarding, procurement_stage: energy_stage, next_key_date: "2025-06-05") }

    it "shows fields with details" do
      within("div#case-details") do
        expect(all("dt.govuk-summary-list__key")[0]).to have_text "Sub-category"
        expect(all("dd.govuk-summary-list__value")[0]).to have_text "DfE Energy for Schools service"
        expect(all("dt.govuk-summary-list__key")[1]).to have_text "Case level"
        expect(all("dd.govuk-summary-list__value")[1]).to have_text "7 - DfE Energy for Schools onboarding case"
        expect(all("dt.govuk-summary-list__key")[2]).to have_text "Stage"
        expect(all("dd.govuk-summary-list__value")[2]).to have_text "Stage 6 - Onboarding form"
        expect(all("dt.govuk-summary-list__key")[3]).to have_text "Source"
        expect(all("dd.govuk-summary-list__value")[3]).to have_text "Energy Onboarding"
        expect(all("dt.govuk-summary-list__key")[4]).to have_text "Next key date and description"
        expect(all("dd.govuk-summary-list__value")[4]).to have_text "05/06/2025"
      end
    end
  end
end
