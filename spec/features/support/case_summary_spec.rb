RSpec.feature "Case summary details" do
  include_context "with an agent"

  before do
    visit support_case_path(support_case)
    click_on "Case details"
  end

  context "when value and support level have been set to nil" do
    let(:support_case) { create(:support_case, :opened, value: nil, support_level: nil) }

    it "shows hypens" do
      within("div#case-details") do
        expect(all("dt.govuk-summary-list__key")[0]).to have_text "Source"
        expect(all("dd.govuk-summary-list__value")[0]).to have_text "-"
        expect(all("dt.govuk-summary-list__key")[1]).to have_text "Case level"
        expect(all("dd.govuk-summary-list__value")[1]).to have_text "Not specified"
        expect(all("dt.govuk-summary-list__key")[2]).to have_text "Case value"
        expect(all("dd.govuk-summary-list__value")[2]).to have_text "Not specified"
      end
    end
  end

  context "when value and support levels have been populated" do
    let(:support_case) { create(:support_case, :opened, value: 123.32, support_level: "L2", source: :incoming_email) }

    it "shows fields with details" do
      within("div#case-details") do
        expect(all("dt.govuk-summary-list__key")[0]).to have_text "Source"
        expect(all("dd.govuk-summary-list__value")[0]).to have_text "Email"
        expect(all("dt.govuk-summary-list__key")[1]).to have_text "Case level"
        expect(all("dd.govuk-summary-list__value")[1]).to have_text "2 - Specific advice"
        expect(all("dt.govuk-summary-list__key")[2]).to have_text "Case value"
        expect(all("dd.govuk-summary-list__value")[2]).to have_text "£123.32"
      end
    end
  end
end
