describe "Case organisation details", :js do
  subject(:support_case) do
    create(:support_case, :opened, organisation: school)
  end

  include_context "with an agent"

  before do
    visit "/support/cases/#{support_case.id}#school-details"
  end

  context "when a school" do
    let(:school) { create(:support_organisation, urn: "12345") }

    it "displays a link open the school details from get information about school service in a new tab" do
      url = "https://www.get-information-schools.service.gov.uk/Establishments/Establishment/Details/12345"
      expect(page).to have_link_to_open_in_new_tab("View school information", href: url)
    end
  end

  context "when a group" do
    subject(:support_case) do
      create(:support_case, :opened, organisation: group)
    end

    let(:group) do
      type = create(:support_establishment_group_type, name: "Multi-academy Trust")

      create(:support_establishment_group, :with_address,
             name: "Group #1",
             uid: "2314",
             establishment_group_type: type)
    end

    it "displays the group name in New cases within CM" do
      visit "/support/cases#new-cases"

      expect(page).to have_link "Group #1"
    end

    it "displays the group name and type on the case page in CM" do
      within("#school-details") do
        expect(all("dd.govuk-summary-list__value")[5]).to have_text "Group #1"
        expect(all("dd.govuk-summary-list__value")[6]).to have_text "Multi-academy Trust"
      end
    end
  end
end
