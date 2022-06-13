RSpec.feature "Case procurement details" do
  include_context "with an agent"

  let(:support_case) { create(:support_case, :opened, procurement: support_procurement) }
  let(:support_procurement) { nil }

  before do
    click_button "Agent Login"
    visit support_case_path(support_case)
    click_on "Case details"
  end

  context "when there are no procurement details" do
    it "does not have a change link" do
      within("div#case-details") do
        expect(all("h2.govuk-heading-m")[2]).to have_text "Procurement details"
        expect(all("h2.govuk-heading-m")[2]).not_to have_link "change"
      end
    end

    it "shows blank fields" do
      within("div#case-details") do
        expect(all("dt.govuk-summary-list__key")[10]).to have_text "Required agreement type"
        expect(all("dt.govuk-summary-list__value")[0]).to have_text ""
        expect(all("dt.govuk-summary-list__key")[11]).to have_text "Route to market"
        expect(all("dt.govuk-summary-list__value")[1]).to have_text ""
        expect(all("dt.govuk-summary-list__key")[12]).to have_text "Reason for route to market"
        expect(all("dt.govuk-summary-list__value")[2]).to have_text ""
        expect(all("dt.govuk-summary-list__key")[13]).to have_text "Framework name"
        expect(all("dt.govuk-summary-list__value")[3]).to have_text ""
        expect(all("dt.govuk-summary-list__key")[14]).to have_text "Procurement start date"
        expect(all("dt.govuk-summary-list__value")[4]).to have_text ""
        expect(all("dt.govuk-summary-list__key")[15]).to have_text "Procurement end date"
        expect(all("dt.govuk-summary-list__value")[5]).to have_text ""
        expect(all("dt.govuk-summary-list__key")[16]).to have_text "Procurement stage"
        expect(all("dt.govuk-summary-list__value")[7]).to have_text ""
      end
    end
  end

  context "when there are procurement details" do
    context "and they are blank" do
      let(:support_procurement) { create(:support_procurement, :blank) }

      it "has a change link" do
        within("div#case-details") do
          expect(all("h2.govuk-heading-m")[2]).to have_text "Procurement details"
          expect(all("h2.govuk-heading-m")[2]).to have_link "change", href: "/support/cases/#{support_case.id}/procurement_details/edit", class: "govuk-link"
        end
      end

      it "shows fields with hyphens" do
        within("div#case-details") do
          expect(all("dt.govuk-summary-list__key")[10]).to have_text "Required agreement type"
          expect(all("dt.govuk-summary-list__value")[0]).to have_text "-"
          expect(all("dt.govuk-summary-list__key")[11]).to have_text "Route to market"
          expect(all("dt.govuk-summary-list__value")[1]).to have_text "-"
          expect(all("dt.govuk-summary-list__key")[12]).to have_text "Reason for route to market"
          expect(all("dt.govuk-summary-list__value")[2]).to have_text "-"
          expect(all("dt.govuk-summary-list__key")[13]).to have_text "Framework name"
          expect(all("dt.govuk-summary-list__value")[3]).to have_text "-"
          expect(all("dt.govuk-summary-list__key")[14]).to have_text "Procurement start date"
          expect(all("dt.govuk-summary-list__value")[4]).to have_text "-"
          expect(all("dt.govuk-summary-list__key")[15]).to have_text "Procurement end date"
          expect(all("dt.govuk-summary-list__value")[5]).to have_text "-"
          expect(all("dt.govuk-summary-list__key")[16]).to have_text "Procurement stage"
          expect(all("dt.govuk-summary-list__value")[6]).to have_text "-"
        end
      end
    end

    context "and they are populated" do
      let(:support_procurement) { create(:support_procurement) }

      it "has a change link" do
        within("div#case-details") do
          expect(all("h2.govuk-heading-m")[2]).to have_text "Procurement details"
          expect(all("h2.govuk-heading-m")[2]).to have_link "change", href: "/support/cases/#{support_case.id}/procurement_details/edit", class: "govuk-link"
        end
      end

      it "shows fields with details" do
        within("div#case-details") do
          expect(all("dt.govuk-summary-list__key")[10]).to have_text "Required agreement type"
          expect(all("dt.govuk-summary-list__value")[0]).to have_text "Ongoing"
          expect(all("dt.govuk-summary-list__key")[11]).to have_text "Route to market"
          expect(all("dt.govuk-summary-list__value")[1]).to have_text "Bespoke Procurement"
          expect(all("dt.govuk-summary-list__key")[12]).to have_text "Reason for route to market"
          expect(all("dt.govuk-summary-list__value")[2]).to have_text "School Preference"
          expect(all("dt.govuk-summary-list__key")[13]).to have_text "Framework name"
          expect(all("dt.govuk-summary-list__value")[3]).to have_text "Test framework"
          expect(all("dt.govuk-summary-list__key")[14]).to have_text "Procurement start date"
          expect(all("dt.govuk-summary-list__value")[4]).to have_text "2 December 2020"
          expect(all("dt.govuk-summary-list__key")[15]).to have_text "Procurement end date"
          expect(all("dt.govuk-summary-list__value")[5]).to have_text "1 December 2021"
          expect(all("dt.govuk-summary-list__key")[16]).to have_text "Procurement stage"
          expect(all("dt.govuk-summary-list__value")[6]).to have_text "Need"
        end
      end
    end
  end
end
