#
# Assert complex case history behaviour
#
RSpec.feature "Support request case history", bullet: :skip do
  include_context "with an agent"

  let(:support_case) do
    create(:support_case, state: "opened")
  end

  let(:agent) { support_case.agent }

  before do
    travel_to Time.zone.local(2021, 3, 20, 12, 0, 0)
    create(:support_interaction, :support_request, case: support_case, agent:)
    create(:support_interaction, :email_to_school, case: support_case, agent:)
    travel_back

    # create(:support_interaction, :note, case: support_case, agent: agent)
    # create(:support_interaction, :note, case: support_case, agent: agent)
    # create(:support_interaction, :phone_call, case: support_case, agent: agent)
    # create(:support_interaction, :email_from_school, case: support_case, agent: agent)

    click_button "Agent Login"
    visit "/support/cases/#{support_case.id}#case-history"
  end

  context "when case is a result of a request for support" do
    it "displays request for support as first time in the case history" do
      within "#case-history #case-history-table tbody:last-child" do
        expect(page).to have_text "Request for support"
        expect(page).to have_text "20 Mar 2021"
      end
    end

    context "when no specification is attached" do
      specify do
        within "#case-history #case-history-table tbody:last-child" do
          expect(page).to have_text "Attached specification"
          expect(page).to have_text "None"
        end
      end
    end
  end

  describe "ordering of interactions" do
    before do
      create(:support_interaction, :note, body: "test", case: support_case, agent:)
      visit "/support/cases/#{support_case.id}#case-history"
    end

    specify do
      within "#case-history" do
        expect(page).to have_text "Case note"
      end
    end
  end
end
