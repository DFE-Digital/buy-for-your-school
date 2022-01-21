require "rails_helper"

describe "Agent sees details of an email" do
  include_context "with an agent"

  before do
    click_button "Agent Login"
  end

  let(:email) { create(:support_email, case: support_case, subject: "Catering requirements") }

  context "when email is assigned to a case" do
    let(:support_case) { create(:support_case, ref: "123456") }

    it "shows the case reference on the email view" do
      visit support_email_path(email)
      expect(page).to have_content("Case ID: 123456")
    end
  end

  context "when email is not assigned to a case" do
    let(:support_case) { nil }

    it "shows no reference to a case" do
      visit support_email_path(email)
      expect(page).not_to have_content("Case ID:")
    end
  end
end
