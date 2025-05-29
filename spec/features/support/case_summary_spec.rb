RSpec.feature "Case summary details" do
  include_context "with an agent"

  before do
    visit support_case_path(support_case)
    click_on "Case details"
  end

  context "when value and support level have been set to nil" do
    let(:support_case) { create(:support_case, :with_fixed_category, :opened, value: nil, support_level: nil) }

    it "shows hyphens" do
      within("div#case-details") do
        expect(all("dt.govuk-summary-list__key")[0]).to have_text "Sub-category"
        expect(all("dd.govuk-summary-list__value")[0]).to have_text "Fixed Category"
        expect(all("dt.govuk-summary-list__key")[1]).to have_text "Case level"
        expect(all("dd.govuk-summary-list__value")[1]).to have_text "Not specified"
        expect(all("dt.govuk-summary-list__key")[2]).to have_text "Case value"
        expect(all("dd.govuk-summary-list__value")[2]).to have_text "Not specified"
        expect(all("dt.govuk-summary-list__key")[3]).to have_text "Origin"
        expect(all("dd.govuk-summary-list__value")[3]).to have_text "Unknown"
        expect(all("dt.govuk-summary-list__key")[4]).to have_text "Source"
        expect(all("dd.govuk-summary-list__value")[4]).to have_text "-"
      end
    end
  end

  context "when value and support levels have been populated" do
    let(:support_case) { create(:support_case, :with_fixed_category, :opened, value: 123.32, support_level: "L2", source: :incoming_email, discovery_method: :non_dfe_publication) }

    it "shows fields with details" do
      within("div#case-details") do
        expect(all("dt.govuk-summary-list__key")[0]).to have_text "Sub-category"
        expect(all("dd.govuk-summary-list__value")[0]).to have_text "Fixed Category"
        expect(all("dt.govuk-summary-list__key")[1]).to have_text "Case level"
        expect(all("dd.govuk-summary-list__value")[1]).to have_text "2 - Specific advice"
        expect(all("dt.govuk-summary-list__key")[2]).to have_text "Case value"
        expect(all("dd.govuk-summary-list__value")[2]).to have_text "£123.32"
        expect(all("dt.govuk-summary-list__key")[3]).to have_text "Origin"
        expect(all("dd.govuk-summary-list__value")[3]).to have_text "Non-DfE newsletter"
        expect(all("dt.govuk-summary-list__key")[4]).to have_text "Source"
        expect(all("dd.govuk-summary-list__value")[4]).to have_text "Email"
      end
    end
  end

  context "when the case is an energy for schools case" do
    let(:dfe_energy_category) { create(:support_category, title: "DfE Energy for Schools service") }
    let(:energy_stage) { create(:support_procurement_stage, key: "onboarding_form", title: "Onboarding form", stage: "6") }
    let(:support_case) { create(:support_case, category: dfe_energy_category, support_level: "L7", source: :energy_onboarding, procurement_stage: energy_stage) }

    it "shows fields with details" do
      within("div#case-details") do
        expect(all("dt.govuk-summary-list__key")[0]).to have_text "Sub-category"
        expect(all("dd.govuk-summary-list__value")[0]).to have_text "DfE Energy for Schools service"
        expect(all("dt.govuk-summary-list__key")[1]).to have_text "Case level"
        expect(all("dd.govuk-summary-list__value")[1]).to have_text "7 - DfE Energy for Schools onboarding case"
        expect(all("dt.govuk-summary-list__key")[2]).to have_text "Procurement stage"
        expect(all("dd.govuk-summary-list__value")[2]).to have_text "Stage 6 - Onboarding form"
        expect(all("dt.govuk-summary-list__key")[3]).to have_text "Source"
        expect(all("dd.govuk-summary-list__value")[3]).to have_text "Energy Onboarding"
      end
    end
  end
end
