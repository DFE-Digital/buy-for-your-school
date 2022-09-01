require "rails_helper"

describe "Agent sees email threads", bullet: :skip do
  include_context "with an agent"

  let(:support_case) { create(:support_case) }

  context "when messages accross multiple threads exist" do
    before do
      create(:support_email, case: support_case, outlook_conversation_id: "OCID1", subject: "Email thread 1", recipients: [{ "name" => "Test 1", "address" => "test1@email.com" }], unique_body: "Email 1")
      create(:support_email, case: support_case, outlook_conversation_id: "OCID2", subject: "Email thread 2", recipients: [{ "name" => "Test 2", "address" => "test2@email.com" }], unique_body: "Email 2")
      create(:support_email, case: support_case, outlook_conversation_id: "OCID2", subject: "Re: Email thread 2", unique_body: "Email 3")

      click_button "Agent Login"
      visit support_case_path(support_case)
      click_link "Messages"
    end

    it "displays each thread within the case messages tab" do
      within "tr", text: "Email thread 1" do
        expect(page).to have_content("Test 1")
      end
      within "tr", text: "Email thread 2" do
        expect(page).to have_content("Test 2")
      end
    end

    describe "within a thread" do
      it "displays each message" do
        within "tr", text: "Email thread 2" do
          click_link "View"
        end

        expect(page).not_to have_content("Email 1")
        expect(page).to have_content("Email 2")
        expect(page).to have_content("Email 3")
      end
    end
  end

  context "when templated messages exist" do
    before do
      create(:support_interaction, :email_to_school, body: "templated message 1", case: support_case, additional_data: { email_template: "f4696e59-8d89-4ac5-84ca-17293b79c337" })
      create(:support_interaction, :email_to_school, body: "templated message 2", case: support_case, additional_data: { email_template: "f4696e59-8d89-4ac5-84ca-17293b79c337" })

      click_button "Agent Login"
      visit support_case_path(support_case)
      click_link "Messages"
    end

    it "displays the templated messages thread within the case messages tab" do
      within "tr", text: "Templated messages" do
        expect(page).to have_content("School Contact")
      end
    end

    describe "within the thread" do
      it "displays each message" do
        within "tr", text: "Templated messages" do
          click_link "View"
        end

        expect(page).to have_content("templated message 1")
        expect(page).to have_content("templated message 2")
        expect(page).to have_content("Template: \"What is a framework?\"")
      end
    end
  end

  context "when logged contacts exist" do
    before do
      create(:support_interaction, :phone_call, body: "contact by phone", case: support_case)
      create(:support_interaction, :email_from_school, body: "logged email", case: support_case)

      click_button "Agent Login"
      visit support_case_path(support_case)
      click_link "Messages"
    end

    it "displays the logged contacts thread within the case messages tab" do
      within "tr", text: "Logged contacts" do
        expect(page).to have_content("School Contact")
      end
    end

    describe "within the thread" do
      it "displays each message" do
        within "tr", text: "Logged contacts" do
          click_link "View"
        end

        expect(page).to have_content("contact by phone")
        expect(page).to have_content("logged email")
        expect(page).to have_content("Phone call")
        expect(page).to have_content("Email from school")
      end
    end
  end
end