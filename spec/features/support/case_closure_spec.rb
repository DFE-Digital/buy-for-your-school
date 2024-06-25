RSpec.feature "Case closure" do
  before do
    agent_is_signed_in(agent:)
  end

  let(:agent) { create(:support_agent, first_name: "ProcOps", last_name: "User") }
  let(:state) { :initial }
  let(:kase_source) { :incoming_email }
  let(:kase) { create(:support_case, state:, source: kase_source, ref: "000001", agent:) }

  describe "Attempting to close/reject the case" do
    before do
      visit "/support/cases/#{kase.id}"
    end

    context "when case is new and from an incoming email" do
      it "closes the case and records the interaction" do
        click_link "Reject case"
        choose "Spam"
        click_button "Save and reject case"
        expect(page).to have_content("Are you sure you want to reject this case?")

        click_button "Reject case"
        expect(page).to have_content("Case has been rejected")
        expect(page).to have_css(".notification-unread-icon")

        visit "/support/cases/#{kase.id}#case-history"
        within "tr", text: "Status change" do
          expect(page).to have_text "From new to rejected by ProcOps User on #{Time.zone.now.to_formatted_s(:short)}. Reason given: Spam"
        end

        visit "/support/notifications"
        expect(page).to have_content "Case Closed - #{kase.ref} by ProcOps"
      end

      context "when no reason is selected" do
        it "displays an error message" do
          click_link "Reject case"
          click_on "Save and reject case"
          expect(find(".govuk-error-summary")).to have_text "You must choose a reason for rejecting the case"
        end
      end
    end

    context "when case is open" do
      let(:state) { :opened }

      it "closes the case and records the interaction" do
        click_link "Reject case"
        choose "No engagement"
        click_button "Save and reject case"
        expect(page).to have_content("Are you sure you want to reject this case?")

        click_button "Reject case"
        expect(page).to have_content("Case has been rejected")
        expect(page).to have_css(".notification-unread-icon")

        visit "/support/cases/#{kase.id}#case-history"
        within "tr", text: "Status change" do
          expect(page).to have_text "From open to rejected by ProcOps User on #{Time.zone.now.to_formatted_s(:short)}. Reason given: No engagement"
        end

        visit "/support/notifications"
        expect(page).to have_content "Case Closed - #{kase.ref} by ProcOps"
      end
    end

    context "when the case is resolved" do
      let(:state) { :resolved }

      it "show the action link" do
        expect(page).to have_link "Reopen case"
      end

      it "does not show the action link" do
        expect(page).not_to have_link "Reject case"
      end
    end

    context "when the case is not new" do
      let(:state) { :closed }

      it "does not show the action link" do
        expect(page).not_to have_link "Reject case"
      end
    end

    context "when the case is not incoming_email" do
      let(:kase_source) { :digital }

      it "does not show the action link" do
        expect(page).not_to have_link "Reject case"
      end
    end
  end
end
