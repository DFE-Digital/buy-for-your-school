describe "Case school details", :js do
  include_context "with a cec agent"

  let(:support_organisation) { create(:support_organisation, urn: "12345", name: "School #1") }

  before do
    visit "/cec/onboarding_cases/#{support_case.id}#school-details"
  end

  context "when the case is an energy for schools case" do
    let(:dfe_energy_category) { create(:support_category, title: "DfE Energy for Schools service") }
    let(:support_case) { create(:support_case, category: dfe_energy_category, organisation: support_organisation, first_name: "Bill", last_name: "Jones", email: "bill.jones@email.com") }

    it "has no change links" do
      within "#school-details" do
        expect(all("dt.govuk-summary-list__key")[0]).to have_text "Contact name"
        expect(all("dd.govuk-summary-list__value")[0]).to have_text "Bill Jones"
        expect(all("dd.govuk-summary-list__actions")[0]).not_to have_link "Change"

        expect(all("dt.govuk-summary-list__key")[1]).to have_text "Contact email"
        expect(all("dd.govuk-summary-list__value")[1]).to have_text "bill.jones@email.com"
        expect(all("dd.govuk-summary-list__actions")[1]).not_to have_link "Change"

        expect(all("dt.govuk-summary-list__key")[2]).to have_text "Organisation name"
        expect(all("dd.govuk-summary-list__value")[2]).to have_text "School #1"
        expect(all("dd.govuk-summary-list__actions")[2]).not_to have_link "Change"

        expect(all("dt.govuk-summary-list__key")[3]).to have_text "Organisation type"
        expect(all("dd.govuk-summary-list__value")[3]).to have_text "name 1"
        expect(all("dd.govuk-summary-list__actions")[3]).not_to have_link "Change"
      end
    end

    it "displays a link open the school details from get information about school service in a new tab" do
      url = "https://www.get-information-schools.service.gov.uk/Establishments/Establishment/Details/12345"
      expect(page).to have_link_to_open_in_new_tab("View school information", href: url)
    end
  end
end
