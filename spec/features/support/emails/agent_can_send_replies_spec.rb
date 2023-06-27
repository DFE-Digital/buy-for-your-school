describe "Agent can reply to incoming emails", js: true, bullet: :skip do
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

    describe "allows agent to send a reply", :with_csrf_protection do
      before do
        template = create(:support_email_template, title: "Energy template", subject: "about energy", body: "energy body")
        create(:support_email_template_attachment, template:)

        click_link "Messages"
        within("#messages-frame") { click_link "View" }
      end

      context "with a signatory template" do
        before do
          click_on "Reply using a signatory template"
        end

        it "shows the recipients" do
          within("#recipient-table") do
            expect(page).to have_text "CC"
            expect(page).to have_text "sender1@email.com"
          end
        end

        it "shows the sent reply" do
          fill_in_editor "Your message", with: "This is a test reply"
          click_button "Send reply"

          within("#messages") do
            expect(page).to have_text "Caseworker"
            expect(page).to have_text "This is a test reply"
          end
        end

        it "transitions the case to on-hold" do
          fill_in_editor "Your message", with: "This is a test reply"
          click_button "Send reply"

          expect(page).to have_text "On Hold"
        end
      end

      context "with a selected template" do
        before do
          click_on "Reply with an email template"
          choose "Energy template"
          click_on "Use selected template"
        end

        it "pre-fills the template boby" do
          expect(page).to have_text "energy body"
        end

        it "adds the template attachments" do
          expect(page).to have_text "attachment.txt"
        end
      end
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
      end
    end
  end
end
