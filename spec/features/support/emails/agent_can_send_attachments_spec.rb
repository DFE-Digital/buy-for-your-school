describe "Agent can add attachments to replies", js: true do
  include_context "with an agent"

  let(:email) { create(:support_email, :inbox, case: support_case) }
  let(:support_case) { create(:support_case) }

  before do
    create(:support_interaction, :email_from_school,
           body: email.body,
           additional_data: { email_id: email.id },
           case: support_case)

    click_button "Agent Login"
    visit support_case_path(support_case)
  end

  context "when replying to an email from the school" do
    before do
      send_reply_service = double("send_reply_service")

      allow(send_reply_service).to receive(:call) do
        reply = create(:support_email, :sent_items, case: support_case, in_reply_to: email, body: "This is a test reply", sender: { name: "Caseworker", address: agent.email })
        create(:support_email_attachment, email: reply)
        create(:support_interaction, :email_to_school, case: support_case, additional_data: { email_id: reply.id })
      end

      allow(Support::Messages::Outlook::SendReplyToEmail).to receive(:new).and_return(send_reply_service)

      click_on "Messages"

      within("#messages-frame") do
        click_on "View"
        find("span", text: "Reply to message").click
        fill_in_editor "Your message", with: "This is a test reply"
      end
    end

    describe "allows agent to add attachments" do
      before do
        attach_file("Add attachments", Rails.root.join("spec/support/assets/support/email_attachments/attachment.txt"))
      end

      it "shows the attached file" do
        expect(page).to have_text "attachment.txt"
      end

      it "allows agent to remove attachments" do
        click_on "Remove"
        expect(page).not_to have_text "attachment.txt"
      end

      it "shows attachment on submitted reply" do
        click_button "Send reply"

        within "#messages .attachments" do
          expect(page).to have_text "attachment.txt"
        end
      end
    end
  end
end
