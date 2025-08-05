describe "Case school details", :js do
  include_context "with a cec agent"

  let(:support_organisation) { create(:support_organisation, urn: "12345", name: "School #1") }

  before do
    visit "/cec/onboarding_cases/#{support_case.id}#school-details"
  end

  context "when the case is an energy for schools case" do
    let(:support_level) { "L7" }
    let(:dfe_energy_category) { create(:support_category, title: "DfE Energy for Schools service") }
    let(:support_case) { create(:support_case, category: dfe_energy_category, organisation: support_organisation, first_name: "Bill", last_name: "Jones", email: "bill.jones@email.com", support_level:) }

    context "when the case is energy sub_category" do
      let(:summary_list_keys) { "dt.govuk-summary-list__key" }
      let(:summary_list_values) { "dd.govuk-summary-list__value" }
      let(:summary_list_actions) { "dd.govuk-summary-list__actions" }

      it "has school details fields and values" do
        within "#school-details" do
          expect(all(summary_list_keys)[0]).to have_text "Contact name"
          expect(all(summary_list_values)[0]).to have_text "Bill Jones"

          expect(all(summary_list_keys)[1]).to have_text "Contact email"
          expect(all(summary_list_values)[1]).to have_text "bill.jones@email.com"

          expect(all(summary_list_keys)[2]).to have_text "Organisation name"
          expect(all(summary_list_values)[2]).to have_text "School #1"

          expect(all(summary_list_keys)[3]).to have_text "Organisation type"
          expect(all(summary_list_values)[3]).to have_text "name 1"
        end
      end

      context "when the support level is L7" do
        it "has no change links" do
          within "#school-details" do
            expect(all(summary_list_actions)[0]).not_to have_link "Change" # Contact name
            expect(all(summary_list_actions)[1]).not_to have_link "Change" # Contact email
            expect(all(summary_list_actions)[2]).not_to have_link "Change" # Organisation name
            expect(all(summary_list_actions)[3]).not_to have_link "Change" # Organisation type
          end
        end
      end

      context "when the support level is NOT L7 (inquiry case)" do
        let(:support_level) { "L6" }

        it "has change links" do
          within "#school-details" do
            expect(all(summary_list_actions)[0]).to have_link "Change"
            expect(all(summary_list_actions)[1]).to have_link "Change"
            expect(all(summary_list_actions)[2]).to have_link "Change"
          end
        end
      end
    end

    it "displays a link open the school details from get information about school service in a new tab" do
      url = "https://www.get-information-schools.service.gov.uk/Establishments/Establishment/Details/12345"
      expect(page).to have_link_to_open_in_new_tab("View school information", href: url)
    end
  end
end
