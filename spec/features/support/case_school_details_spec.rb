describe "Case school details" do
  include_context "with an agent"

  let(:support_organisation) { create(:support_organisation, urn: "12345", name: "School #1") }

  before do
    visit "/support/cases/#{support_case.id}#school-details"
  end

  context "when open case" do
    let(:support_case) { create(:support_case, :opened, organisation: support_organisation, first_name: "John", last_name: "Smith", email: "john.smith@email.com", phone_number: "07755121121", extension_number: "8121") }

    it "displays a link open the school details from get information about school service in a new tab" do
      url = "https://www.get-information-schools.service.gov.uk/Establishments/Establishment/Details/12345"
      expect(page).to have_link_to_open_in_new_tab("View school information", href: url)
    end

    it "has change links for contact details and organisation" do
      within "#school-details" do
        expect(all("dt.govuk-summary-list__key")[0]).to have_text "Contact name"
        expect(all("dd.govuk-summary-list__value")[0]).to have_text "John Smith"
        expect(all("dd.govuk-summary-list__actions")[0]).to have_link "Change"

        expect(all("dt.govuk-summary-list__key")[1]).to have_text "Contact phone"
        expect(all("dd.govuk-summary-list__value")[1]).to have_text "07755121121"
        expect(all("dd.govuk-summary-list__actions")[1]).to have_link "Change"

        expect(all("dt.govuk-summary-list__key")[2]).to have_text "Contact extension"
        expect(all("dd.govuk-summary-list__value")[2]).to have_text "8121"
        expect(all("dd.govuk-summary-list__actions")[2]).to have_link "Change"

        expect(all("dt.govuk-summary-list__key")[3]).to have_text "Contact email"
        expect(all("dd.govuk-summary-list__value")[3]).to have_text "john.smith@email.com"
        expect(all("dd.govuk-summary-list__actions")[3]).to have_link "Change"

        expect(all("dt.govuk-summary-list__key")[4]).to have_text "Organisation name"
        expect(all("dd.govuk-summary-list__value")[4]).to have_text "School #1"
        expect(all("dd.govuk-summary-list__actions")[4]).to have_link "Change"
      end
    end
  end

  context "when closed case" do
    let(:support_case) { create(:support_case, state: :closed, organisation: support_organisation, first_name: "Bill", last_name: "Jones", email: "bill.jones@email.com", phone_number: "07744121121", extension_number: "4121") }

    it "has no change links" do
      within "#school-details" do
        expect(all("dt.govuk-summary-list__key")[0]).to have_text "Contact name"
        expect(all("dd.govuk-summary-list__value")[0]).to have_text "Bill Jones"
        expect(all("dd.govuk-summary-list__actions")[0]).not_to have_link "Change"

        expect(all("dt.govuk-summary-list__key")[1]).to have_text "Contact phone"
        expect(all("dd.govuk-summary-list__value")[1]).to have_text "07744121121"
        expect(all("dd.govuk-summary-list__actions")[1]).not_to have_link "Change"

        expect(all("dt.govuk-summary-list__key")[2]).to have_text "Contact extension"
        expect(all("dd.govuk-summary-list__value")[2]).to have_text "4121"
        expect(all("dd.govuk-summary-list__actions")[2]).not_to have_link "Change"

        expect(all("dt.govuk-summary-list__key")[3]).to have_text "Contact email"
        expect(all("dd.govuk-summary-list__value")[3]).to have_text "bill.jones@email.com"
        expect(all("dd.govuk-summary-list__actions")[3]).not_to have_link "Change"

        expect(all("dt.govuk-summary-list__key")[4]).to have_text "Organisation name"
        expect(all("dd.govuk-summary-list__value")[4]).to have_text "School #1"
        expect(all("dd.govuk-summary-list__actions")[4]).not_to have_link "Change"
      end
    end
  end
end
