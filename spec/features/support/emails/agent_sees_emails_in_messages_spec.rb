require "rails_helper"

describe "Agent sees emails in messages" do
  include_context "with an agent"

  let(:email) { create(:support_email, origin, case: support_case, body: "Catering requirements") }
  let(:support_case) { create(:support_case) }

  before do
    create(:support_interaction, interaction_type,
           body: email.body,
           additional_data: { email_id: email.id },
           case: support_case)

    click_button "Agent Login"
  end

  context "when there are interactions for emails sent from the school" do
    let(:origin) { :inbox }
    let(:interaction_type) { :email_from_school }

    it "displays the email details" do
      visit support_case_path(support_case)

      within "#messages" do
        expect(page).to have_content("Catering requirements")
        expect(page).to have_content(email.sent_at.strftime("%e %B %Y"))
        expect(page).to have_content("Sender 1")
        expect(page).to have_content("from School")
      end
    end

    context "when the email contains attachments" do
      before do
        create(:support_email_attachment, email: email)
      end

      it "allows the user to download the attachment" do
        visit support_case_path(support_case)

        within "#messages" do
          click_link "attachment.txt"
        end

        expect(page).to have_content("This is an attachment for an email")
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
    let(:origin) { :sent_items }
    let(:interaction_type) { :email_to_school }

    it "displays the email details under a title 'Email to school'" do
      visit support_case_path(support_case)

      within "#messages" do
        expect(page).to have_content("Catering requirements")
        expect(page).to have_content(email.sent_at.strftime("%e %B %Y"))
        expect(page).to have_content("Sender 1")
        expect(page).to have_content("Caseworker")
      end
    end
  end
end
