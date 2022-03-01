RSpec.describe "Case problem description" do
  include_context "with an agent"

  before do
    click_button "Agent Login"
  end

  context "when a case is created via 'create a case'" do
    # 'create a case' includes case source types 'nw_hub', 'sw_hub' and nil

    let(:support_case) { create(:support_case, source: nil) }

    before do
      visit "/support/cases/#{support_case.id}"
    end

    it "shows a change link for the problem description in case details" do
      within("div#case-details") do
        within(all("div.govuk-summary-list__row")[1]) do
          expect(page).to have_text "Description of problem"
          expect(page).to have_text "This is an example request for support - please help!"
          expect(page).to have_link "Change", href: "/support/cases/#{support_case.id}/edit", class: "govuk-link"
        end
      end
    end

    it "allows a user to update the problem description" do
      within("div#case-details") do
        within(all("div.govuk-summary-list__row")[1]) do
          click_on "Change"
        end
      end

      fill_in "edit_case_form[request_text]", with: "updated problem"
      click_button "Save changes"
      expect(page).to have_text "Description of problem updated successfully"

      within("div#case-details") do
        within(all("div.govuk-summary-list__row")[1]) do
          expect(page).to have_text "updated problem"
        end
      end
    end
  end
end
