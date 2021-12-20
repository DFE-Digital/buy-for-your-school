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
             sent_at: Time.zone.parse("25-12-2021 12:00"),
             case: create(:support_case, ref: "012345"))

      create(:support_email,
             subject: "Email subject 2 - Not linked to a case",
             sender: { address: "sender2@email.com", name: "Sender 2" },
             sent_at: Time.zone.parse("25-12-2020 15:00"),
             case: nil)
    end

    specify "then I can see them listed without going to a case" do
      within ".govuk-header" do
        click_link "Emails"
      end

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
end
