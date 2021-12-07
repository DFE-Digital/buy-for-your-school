#
# Assert complex case history behaviour
#
RSpec.feature "Support request case history" do
  include_context "with an agent"

  let(:support_case) do
    create(:support_case, state: "opened")
  end

  let(:agent) { support_case.agent }

  before do
    travel_to Time.zone.local(2021, 3, 20, 12, 0, 0)

    create(:support_interaction, :support_request, case: support_case, agent: agent)
    # create(:support_interaction, :note, case: support_case, agent: agent)
    # create(:support_interaction, :note, case: support_case, agent: agent)
    # create(:support_interaction, :phone_call, case: support_case, agent: agent)
    # create(:support_interaction, :email_from_school, case: support_case, agent: agent)
    create(:support_interaction, :email_to_school, case: support_case, agent: agent)

    click_button "Agent Login"
    visit "/support/cases/#{support_case.id}#case-history"
  end

  describe "first event" do
    specify "heading" do
      within "#case-history" do
        expect(find_all("h2.govuk-accordion__section-heading")[1]).to have_text "Request for support"
      end
    end

    specify "timestamp" do
      within "#case-history" do
        expect(find_all("div.govuk-accordion__section-summary")[1]).to have_text "20 March 2021 at 12:00"
      end
    end

    context "when no specification is attached" do
      specify do
        within "#case-history" do
          expect(find_all("dt.govuk-summary-list__key")[3]).to have_text "Attached specification"
          expect(find_all("dd.govuk-summary-list__value")[3]).to have_text "None"
        end
      end
    end
  end

  describe "email interaction" do
    specify do
      within "#case-history" do
        expect(find_all("dd.govuk-summary-list__value")[1]).to have_link_to_open_in_new_tab("Open email preview in new tab")
      end
    end
  end
end
