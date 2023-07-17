RSpec.feature "Case procurement details" do
  include_context "with an agent"

  let(:support_case) { create(:support_case, :opened, procurement: support_procurement) }
  let(:support_procurement) { nil }

  before do
    visit support_case_path(support_case)
    click_on "Case details"
  end

  context "when there are no procurement details" do
    it "does not have a change link" do
      within("div#case-details") do
        expect(all("h3.govuk-heading-m")[2]).to have_text "Procurement details"
        expect(all("h3.govuk-heading-m")[2]).not_to have_link "change"
      end
    end
  end

  context "when there are procurement details" do
    context "and they are blank" do
      let(:support_procurement) { create(:support_procurement, :blank) }

      it "has a change link" do
        within("div#case-details") do
          expect(all("h3.govuk-heading-m")[2]).to have_text "Procurement details"
          expect(all("h3.govuk-heading-m")[2]).to have_link "change", href: "/support/cases/#{support_case.id}/procurement_details/edit", class: "govuk-link"
        end
      end
    end

    context "and they are populated" do
      let(:support_procurement) { create(:support_procurement, stage: :market_analysis) }

      it "has a change link" do
        within("div#case-details") do
          expect(all("h3.govuk-heading-m")[2]).to have_text "Procurement details"
          expect(all("h3.govuk-heading-m")[2]).to have_link "change", href: "/support/cases/#{support_case.id}/procurement_details/edit", class: "govuk-link"
        end
      end

      it "shows fields with details" do
        within("div#case-details") do
          within ".govuk-summary-list__row", text: "Required agreement type" do
            expect(page).to have_content("Ongoing")
          end

          within ".govuk-summary-list__row", text: "Route to market" do
            expect(page).to have_content("Bespoke Procurement")
          end

          within ".govuk-summary-list__row", text: "Reason for route to market" do
            expect(page).to have_content("School Preference")
          end

          within ".govuk-summary-list__row", text: "Framework name" do
            expect(page).to have_content("Test framework")
          end

          within ".govuk-summary-list__row", text: "Procurement start date" do
            expect(page).to have_content("2 December 2020")
          end

          within ".govuk-summary-list__row", text: "Procurement end date" do
            expect(page).to have_content("1 December 2021")
          end

          within ".govuk-summary-list__row", text: "Legacy procurement stage" do
            expect(page).to have_content("Market Analysis")
          end
        end
      end
    end
  end
end
