require "rails_helper"

describe "Agent sees email threads", bullet: :skip do
  context "when messages accross multiple threads exist" do
    include_context "with an agent"

    let(:support_case) { create(:support_case) }

    before do
      create(:support_email, case: support_case, outlook_conversation_id: "OCID1", subject: "Email thread 1", recipients: [{ "name" => "Test 1" }], unique_body: "Email 1")
      create(:support_email, case: support_case, outlook_conversation_id: "OCID2", subject: "Email thread 2", recipients: [{ "name" => "Test 2" }], unique_body: "Email 2")
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
end
