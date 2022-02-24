RSpec.feature "Completed framework requests show org or group name in CM" do
  include_context "with an agent"

  context "when user creates a FaF request for a group" do
    let!(:support_establishment_group) { create(:support_establishment_group, :with_address, name: "Group #1", uid: "2314", establishment_group_type: create(:support_establishment_group_type, name: "Multi-academy Trust")) }
    let!(:support_case) { create(:support_case, :opened, organisation: support_establishment_group) }

    before do
      click_button "Agent Login"
      visit "/support/cases/#{support_case.id}#school-details"
    end

    it "displays the group name in New cases within CM" do
      visit "/support/cases#new-cases"

      expect(page).to have_link "Group #1"
    end

    it "displays the group name and type on the case page in CM" do
      within("#school-details") do
        expect(all("dd.govuk-summary-list__value")[3]).to have_text "Group #1"
        expect(all("dd.govuk-summary-list__value")[4]).to have_text "Multi-academy Trust"
      end
    end
  end
end
