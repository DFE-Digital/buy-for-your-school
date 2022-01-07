require "rails_helper"

describe "Agent sees emails in case history" do
  include_context "with an agent"

  let(:email) { create(:support_email, case: support_case, subject: "Catering requirements") }
  let(:support_case) { create(:support_case) }

  before do
    create(:support_interaction, interaction_type,
           body: email.body,
           additional_data: { email_id: email.id },
           case: support_case)

    click_button "Agent Login"
  end

  context "when there are interactions for emails sent from the school" do
    let(:interaction_type) { :email_from_school }

    it "displays the email details under a title 'Email from school'" do
      visit support_case_path(support_case)

      within "#case-history .govuk-accordion__section", text: "Email from school" do
        expect(page).to have_content("Catering requirements")
        expect(page).to have_content(email.sent_at.strftime("%e %B %Y"))
        expect(page).to have_link("Open email preview in new tab", href: support_email_path(email))
      end
    end

    context "when the incoming_email feature is disabled" do
      before { allow(Features).to receive(:enabled?).with(:incoming_emails).and_return(false) }

      it "does not display interactions regarding emails_from_school" do
        visit support_case_path(support_case)

        within "#case-history" do
          expect(page).not_to have_content("Email from school")
          expect(page).not_to have_content("Catering requirements")
        end
      end
    end
  end

  context "when there are interactions for emails sent to the school" do
    let(:interaction_type) { :email_to_school }

    it "displays the email details under a title 'Email to school'" do
      visit support_case_path(support_case)

      within "#case-history .govuk-accordion__section", text: "Email to school" do
        expect(page).to have_content("Catering requirements")
        expect(page).to have_content(email.sent_at.strftime("%e %B %Y"))
        expect(page).to have_link("Open email preview in new tab", href: support_email_path(email))
      end
    end
  end
end
