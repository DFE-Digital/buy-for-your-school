require "rails_helper"

describe "Agent sees a list of emails seperate to cases" do
  include_context "with an agent"

  before do
    click_button "Agent Login"
  end

  context "when the :incoming_emails feature flag is disabled" do
    before { allow(Features).to receive(:enabled?).with(:incoming_emails).and_return(false) }

    it "does not show the Notifications link to access emails" do
      visit support_root_path
      expect(page).not_to have_link("Notifications")
    end
  end

  context "when there are emails in the system" do
    before do
      create(:support_email, :inbox,
             subject: "Email subject 1 - Linked to case 012345",
             sender: { address: "sender1@email.com", name: "Sender 1" },
             recipients: [{ address: "recipient1@email.com", name: "Recipient 1" }],
             sent_at: Time.zone.parse("25-12-2021 12:00"),
             case: create(:support_case, ref: "012345"),
             body: "<p>Email 1 body</p>")

      create(:support_email, :inbox,
             subject: "Email subject 2 - Not linked to a case",
             sender: { address: "sender2@email.com", name: "Sender 2" },
             sent_at: Time.zone.parse("25-12-2020 15:00"),
             case: nil,
             body: "<p>Email 2 body</p>")

      create(:support_email, :sent_items,
             subject: "RE: Email subject 2",
             sender: { address: "sender3@email.com", name: "Sender 3" },
             sent_at: Time.zone.parse("25-12-2020 15:00"),
             case: nil,
             body: "<p>Email 3 body, reply to 2</p>")
    end

    specify "then I can see emails from the inbox listed without going to a case" do
      click_link "Notifications"

      within "#new-emails" do
        within "tr.email-row", text: "Email subject 1 - Linked to case 012345" do
          expect(page).to have_css(".email-sent-at", text: "25-12-2021 12:00")
          expect(page).to have_css(".email-case-ref", text: "012345")
          expect(page).to have_css(".email-sent-by", text: "Sender 1")
        end

        within "tr.email-row", text: "Email subject 2 - Not linked to a case" do
          expect(page).to have_css(".email-sent-at", text: "25-12-2020 15:00")
          expect(page).to have_css(".email-sent-by", text: "Sender 2")
        end
      end
    end

    specify "then I do not see emails from the sent folder" do
      click_link "Notifications"

      expect(page).not_to have_content("RE: Email subject 2")
    end

    specify "then I can click on an email to see its body" do
      click_link "Notifications"

      within "#new-emails" do
        click_link "Email subject 1"
      end

      within ".email-sent-by" do
        expect(page).to have_content("Sender 1 <sender1@email.com>")
      end

      within ".email-recipients" do
        expect(page).to have_content("Recipient 1 <recipient1@email.com>")
      end

      within ".email-subject" do
        expect(page).to have_content("Email subject 1 - Linked to case 012345")
      end

      within ".email-preview-body" do
        expect(page).to have_content("Email 1 body")
      end
    end

    context "when the email contains attachments" do
      let(:email) { Support::Email.first }

      before do
        create(:support_email_attachment, email: email)
      end

      it "allows the user to download the attachment" do
        visit support_email_path(email)

        within ".email-attachments" do
          click_link "attachment.txt"
        end

        expect(page).to have_content("This is an attachment for an email")
      end
    end

    context "when I am assigned to a case" do
      before { agent.cases << Support::Email.first.case }

      specify "then I can see emails for only cases I am assigned to" do
        click_link "Notifications"
        click_link "My Case Emails"

        expect(page).to have_css(".my-case-emails-count", text: 1)

        within "#my-case-emails" do
          within "tr.email-row", text: "Email subject 1 - Linked to case 012345" do
            expect(page).to have_css(".email-sent-at", text: "25-12-2021 12:00")
            expect(page).to have_css(".email-case-ref", text: "012345")
            expect(page).to have_css(".email-sent-by", text: "Sender 1")
          end

          expect(page).not_to have_content("Email subject 2 - Not linked to a case")
        end
      end
    end
  end
end
