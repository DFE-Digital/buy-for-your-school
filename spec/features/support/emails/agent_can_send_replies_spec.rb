describe "Agent can reply to incoming emails", :js, bullet: :skip do
  include_context "with an agent"

  let(:email) { create(:support_email, origin, ticket: support_case) }
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
      allow(Email).to receive(:cache_message).and_return(double.as_null_object)
      allow(MicrosoftGraph).to receive(:client).and_return(double.as_null_object)
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
