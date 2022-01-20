require "rails_helper"

describe "Agent sees emails in case history" do
  include_context "with an agent"

  let(:is_read) { true }
  let(:email) { create(:support_email, case: support_case, subject: "Catering requirements", is_read: is_read) }
  let(:support_case) { create(:support_case) }

  before do
    create(:support_interaction, :email_from_school,
           body: email.body,
           additional_data: { email_id: email.id },
           case: support_case)

    click_button "Agent Login"
    visit support_case_path(support_case)
  end

  context "when email is unread" do
    let(:is_read) { false }

    it "displays UNREAD next to the interaction in case history" do
      within "#case-history .govuk-accordion__section", text: "Catering requirements" do
        expect(page).to have_css(".email-read-status", text: "Unread")
      end
    end

    describe "in the email view" do
      before do
        within "#case-history .govuk-accordion__section", text: "Catering requirements" do
          click_link "Open email preview in new tab"
        end
      end

      it "displays UNREAD next to the header" do
        expect(page).to have_css(".email-read-status", text: "Unread")
      end

      specify "then I can mark the email as read" do
        click_button "Mark as read"
        expect(email.reload.is_read).to be(true)
      end
    end
  end

  context "when email is read" do
    it "does not display UNREAD next to the interaction in case history" do
      within "#case-history .govuk-accordion__section", text: "Catering requirements" do
        expect(page).not_to have_css(".email-read-status", text: "Unread")
      end
    end

    describe "in the email view" do
      before do
        within "#case-history .govuk-accordion__section", text: "Catering requirements" do
          click_link "Open email preview in new tab"
        end
      end

      it "does not display UNREAD next to the header" do
        expect(page).not_to have_css(".email-read-status", text: "Unread")
      end

      specify "then I can mark the email as unread" do
        click_button "Mark as unread"
        expect(email.reload.is_read).to be(false)
      end
    end
  end
end
