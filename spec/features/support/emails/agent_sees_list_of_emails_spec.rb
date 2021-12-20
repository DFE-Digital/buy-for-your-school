require "rails_helper"

describe "Agent sees a list of emails seperate to cases" do
  include_context "with an agent"

  before do
    click_button "Agent Login"
  end

  context "when there are emails in the system" do
    before do
      create(:support_email,
             subject: "Email subject 1 - Linked to case 012345",
             sender: { address: "sender1@email.com", name: "Sender 1" },
             recipients: [{ address: "recipient1@email.com", name: "Recipient 1" }],
             sent_at: Time.zone.parse("25-12-2021 12:00"),
             case: create(:support_case, ref: "012345"),
             body: "<p>Email 1 body</p>")

      create(:support_email,
             subject: "Email subject 2 - Not linked to a case",
             sender: { address: "sender2@email.com", name: "Sender 2" },
             sent_at: Time.zone.parse("25-12-2020 15:00"),
             case: nil,
             body: "<p>Email 2 body</p>")

      click_link "Emails"
    end

    specify "then I can see them listed without going to a case" do
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

    specify "then I can click on an email to see its body" do
      click_link "Email subject 1"

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
  end
end
