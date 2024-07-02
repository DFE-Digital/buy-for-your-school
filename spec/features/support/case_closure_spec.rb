RSpec.feature "Case closure" do
  before do
    agent_is_signed_in
  end

  let(:state) { :initial }
  let(:kase_source) { :incoming_email }
  let(:kase) { create(:support_case, state:, source: kase_source, ref: "000001") }

  describe "Attempting to close the case" do
    before do
      visit "/support/cases/#{kase.id}"
    end

    context "when case is new and from an incoming email" do
      it "closes the case and records the interaction" do
        click_link "Close case"
        choose "Spam"
        click_button "Save and close case"
        expect(page).to have_content("Case has been closed")

        visit "/support/cases/#{kase.id}#case-history"
        within "tr", text: "Status change" do
          expect(page).to have_text "From new to closed by first_name last_name on #{Time.zone.now.to_formatted_s(:short)}. Reason given: Spam"
        end
      end

      context "when no reason is selected" do
        it "displays an error message" do
          click_link "Close case"
          click_on "Save and close case"
          expect(find(".govuk-error-summary")).to have_text "You must choose a reason for closing the case"
        end
      end
    end

    context "when the case is resolved" do
      let(:state) { :resolved }

      it "show the action link" do
        expect(page).to have_link "Reopen case"
      end
    end

    context "when the case is not new" do
      let(:state) { :opened }

      it "does not show the action link" do
        expect(page).not_to have_link "Close case"
      end
    end

    context "when the case is not incoming_email" do
      let(:kase_source) { :digital }

      it "does not show the action link" do
        expect(page).not_to have_link "Close case"
      end
    end
  end
end
