#
# Assert complex case history behaviour
#
RSpec.feature "Support request case history" do
  include_context "with an agent"

  let(:support_case) do
    create(:support_case, state: "opened", agent: agent)
  end

  before do
    travel_to Time.zone.local(2021, 3, 20, 12, 0, 0)

    create(:support_interaction, :support_request, case: support_case, agent: agent)
    # create(:support_interaction, :note, case: support_case, agent: agent)
    # create(:support_interaction, :note, case: support_case, agent: agent)
    # create(:support_interaction, :phone_call, case: support_case, agent: agent)
    # create(:support_interaction, :email_from_school, case: support_case, agent: agent)
    # create(:support_interaction, :email_to_school, case: support_case, agent: agent)

    visit "/support/cases/#{support_case.id}#case-history"
  end

  describe "first event" do
    specify "heading" do
      within "#case-history" do
        expect(find("h2.govuk-accordion__section-heading")).to have_text "Request for support"
      end
    end

    specify "timestamp" do
      within "#case-history" do
        expect(find("div.govuk-accordion__section-summary")).to have_text "20 March 2021 at 12:00"
      end
    end

    context "when no specification is attached" do
      specify do
        within "#case-history" do
          expect(find_all("dt.govuk-summary-list__key")[1]).to have_text "Attached specification"
          expect(find_all("dd.govuk-summary-list__value")[1]).to have_text "None"
        end
      end
    end
  end
end
