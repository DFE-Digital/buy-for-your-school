NAVIGATED_TO_MESSAGE_VIEW = "with navigated to messages view".freeze
describe "Agent can reply to incoming emails", :js do
  include_context "with an agent"
  include_context "with a support case and email"

  context "when there is an email from the school" do
    before do
      allow(Email).to receive(:cache_message).and_return(double.as_null_object)
      allow(MicrosoftGraph).to receive(:client).and_return(double.as_null_object)
    end

    describe "allows agent to send a reply", :with_csrf_protection do
      include_context NAVIGATED_TO_MESSAGE_VIEW

      before do
        template = create(:support_email_template, title: "Energy template", subject: "about energy", body: "energy body")
        create(:support_email_template_attachment, template:)
      end

      context "with a signatory template" do
        before { click_on "Reply with signature" }

        it "shows the recipients" do
          within("#recipient-table") do
            expect(page).to have_text "CC"
            expect(page).to have_text "sender1@email.com"
          end
        end
      end

      context "with a selected template" do
        before do
          click_on "Reply with template"
          choose "Energy template"
          click_on "Use selected template"
        end

        it "pre-fills the template body" do
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

    include_context NAVIGATED_TO_MESSAGE_VIEW

    it "does not show the reply form" do
      within("#messages") do
        expect(page).not_to have_text "Reply to message"
      end
    end
  end

  context "when there is a logged email" do
    let(:additional_data) { {} }

    include_context NAVIGATED_TO_MESSAGE_VIEW, frame: "#thread_logged_contacts"

    it "does not show the reply form" do
      within("#messages") do
        expect(page).not_to have_text "Reply to message"
      end
    end
  end
end
