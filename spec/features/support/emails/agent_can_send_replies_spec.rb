describe "Agent can reply to incoming emails", js: true do
  include_context "with an agent"

  let(:email) { create(:support_email, origin, case: support_case) }
  let(:support_case) { create(:support_case) }
  let(:origin) { :inbox }
  let(:interaction_type) { :email_from_school }
  let(:additional_data) { { email_id: email.id } }

  before do
    create(:support_interaction, interaction_type,
           body: email.body,
           additional_data:,
           case: support_case)

    click_button "Agent Login"
    visit support_case_path(support_case)
  end

  context "when there is an email from the school" do
    before do
      send_reply_service = double("send_reply_service")

      allow(send_reply_service).to receive(:call) do
        reply = create(:support_email, :sent_items, case: support_case, in_reply_to: email, unique_body: "This is a test reply", sender: { name: "Caseworker", address: agent.email })
        create(:support_interaction, :email_to_school, case: support_case, additional_data: { email_id: reply.id })
      end

      allow(Support::Messages::Outlook::SendReplyToEmail).to receive(:new).and_return(send_reply_service)
    end

    describe "allows agent to send a reply" do
      before do
        click_link "Messages"
        within("#messages-frame") { click_link "View" }

        find("span", text: "Reply to message").click
        fill_in_editor "Your message", with: "This is a test reply"
        click_button "Send reply"
      end

      it "shows the reply" do
        within("#messages") do
          expect(page).to have_text "Caseworker"
          expect(page).to have_text "This is a test reply"
        end
      end
    end
  end

  describe "a caseworker must enter a reply body" do
    before do
      click_link "Messages"
      within("#messages-frame") { click_link "View" }

      find("span", text: "Reply to message").click
      sleep 0.2
      fill_in_editor "Your message", with: ""
      click_button "Send reply"
    end

    it "shows a warning about not sending an empty reply" do
      expect(page).to have_content("The reply body cannot be blank")
    end
  end

  context "when there is an email from the caseworker" do
    let(:origin) { :sent_items }
    let(:interaction_type) { :email_to_school }

    before do
      click_link "Messages"
      within("#messages-frame") { click_link "View" }
    end

    it "does not show the reply form" do
      within("#messages") do
        expect(page).not_to have_text "Reply to message"
        expect(page).not_to have_button "Send reply"
      end
    end
  end

  context "when there is a logged email" do
    let(:additional_data) { {} }

    before do
      click_link "Messages"
      within("#thread_logged_contacts") do
        click_link "View"
      end
    end

    it "does not show the reply form" do
      within("#messages") do
        expect(page).not_to have_text "Reply to message"
        expect(page).not_to have_button "Send reply"
      end
    end
  end
end
