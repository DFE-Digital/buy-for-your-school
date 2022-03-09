RSpec.feature "Case closure" do
  before do
    agent_is_signed_in
  end

  let(:state) { :initial }
  let(:kase_source) { :incoming_email }
  let(:kase) { create(:support_case, state: state, source: kase_source, ref: "000001") }
  let(:activity_log_item) { Support::ActivityLogItem.last }
  let(:interaction) { kase.interactions.last }

  describe "Function" do
    before do
      visit "/support/cases/#{kase.id}"
    end

    context "when case is new and from an incoming email" do
      it "closes the case and records the interaction" do
        click_link "Close case"
        choose "Spam"
        click_button "Save and close case"

        expect(kase.reload.closed?).to be true
        expect(activity_log_item.support_case_id).to eq kase.id
        expect(activity_log_item.action).to eq "close_case"
        expect(activity_log_item.data).to eq({ "closure_reason" => "spam" })

        visit "/support/cases/#{kase.id}#case-history"

        expect(find("##{interaction.id}")).to have_text "Status change"
        expect(find("##{interaction.id}")).to have_text "From new to closed by first_name last_name on #{Time.zone.now.to_formatted_s(:short)}. Reason given: Spam"
      end
    end

    context "when the case is resolved" do
      let(:state) { :resolved }

      before { click_link "Close case" }

      it "closes the case and records the interaction" do
        expect(kase.reload.closed?).to be true
        expect(activity_log_item.support_case_id).to eq kase.id
        expect(activity_log_item.action).to eq "close_case"
        expect(activity_log_item.data).to eq({ "closure_reason" => "Resolved case closed by agent" })

        visit "/support/cases/#{kase.id}#case-history"

        expect(find("##{interaction.id}")).to have_text "Status change"
        expect(find("##{interaction.id}")).to have_text "From resolved to closed by first_name last_name on #{Time.zone.now.to_formatted_s(:short)}"
      end

      it "removes the case from my cases tab" do
        visit support_cases_path
        expect(page).not_to have_css("#my-cases .case-row", text: "000001")

        within "#all-cases .case-row", text: "000001" do
          expect(page).to have_css(".case-status", text: "Closed")
        end
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

  describe "Pages" do
    before do
      visit "/support/cases/#{kase.id}/closures/edit"
    end

    it "displays the closure reason page" do
      expect(find("legend")).to have_text "Close case"
      expect(page).to have_text "Select reason for closing case."

      expect(all(".govuk-radios__item")[0]).to have_text "Spam"
      expect(all(".govuk-radios__item")[1]).to have_text "Out of scope"
      expect(all(".govuk-radios__item")[2]).to have_text "Other"

      expect(page).to have_button "Save and close case"
    end

    it "displays the flash message upon saving" do
      choose "Spam"
      click_button "Save and close case"
      expect(find(".govuk-notification-banner")).to have_text "Case has been closed"
    end
  end

  describe "Error messages" do
    before do
      visit "/support/cases/#{kase.id}/closures/edit"
    end

    context "when the case is not new" do
      let(:state) { :opened }

      it "displays an error message" do
        expect(find(".govuk-notification-banner")).to have_text "Only new cases created from emails can be closed"
      end
    end

    context "when the case is not incoming" do
      let(:kase_source) { :digital }

      it "displays an error message" do
        expect(find(".govuk-notification-banner")).to have_text "Only new cases created from emails can be closed"
      end
    end

    context "when no reason is selected" do
      before do
        click_on "Save and close case"
      end

      it "displays an error message" do
        expect(find(".govuk-error-summary")).to have_text "You must choose a reason for closing the case"
      end
    end
  end
end
