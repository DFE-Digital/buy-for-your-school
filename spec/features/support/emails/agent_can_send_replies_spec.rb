describe "Agent can reply to incoming emails" do
  include_context "with an agent"

  let(:email) { create(:support_email, origin, case: support_case) }
  let(:support_case) { create(:support_case) }
  let(:origin) { :inbox }
  let(:interaction_type) { :email_from_school }
  let(:additional_data) { { email_id: email.id } }

  before do
    create(:support_interaction, interaction_type,
           body: email.body,
           additional_data: additional_data,
           case: support_case)

    click_button "Agent Login"
    visit support_case_path(support_case)
  end

  context "when there is an email from the school" do
    describe "allows agent to send a reply" do
      before do
        within("#messages") do
          find("span", text: "Reply to message").click
          fill_in "message_reply_form[body]", with: "This is a test reply"
          click_button "Preview and send"
        end
        click_button "Send"
      end

      it "shows the reply" do
        within("#messages") do
          expect(page).to have_text "Caseworker"
          expect(page).to have_text "This is a test reply"
          expect(page).to have_text "RegardsProcurement SpecialistProcurement SpecialistGet help buying for schools"
        end
      end
    end
  end

  context "when there is an email from the caseworker" do
    let(:origin) { :sent_items }
    let(:interaction_type) { :email_to_school }

    it "does not show the reply form" do
      within("#messages") do
        expect(page).not_to have_text "Reply to message"
        expect(page).not_to have_button "Send reply"
      end
    end
  end

  context "when there is a logged email" do
    let(:additional_data) { {} }

    it "does not show the reply form" do
      within("#messages") do
        expect(page).not_to have_text "Reply to message"
        expect(page).not_to have_button "Send reply"
      end
    end
  end
end
