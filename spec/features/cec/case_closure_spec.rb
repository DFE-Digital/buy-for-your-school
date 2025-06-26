RSpec.feature "Case closure" do
  include_context "with a cec agent"

  let(:state) { :initial }
  let(:kase_source) { :incoming_email }
  let(:support_case) { create(:support_case, state:, source: kase_source, ref: "000001", agent:) }

  describe "Attempting to close/reject the case" do
    before do
      visit cec_onboarding_case_path(support_case)
    end

    context "when case is new and from an incoming email" do
      it "closes the case and records the interaction" do
        click_link "Reject case"
        choose "Spam"
        click_button "Save and reject case"
        expect(page).to have_content("Are you sure you want to reject this case?")

        click_button "Reject case"
        expect(page).to have_content("Case has been rejected")
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
