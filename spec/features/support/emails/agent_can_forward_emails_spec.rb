describe "Agent can forward an email", :js, bullet: :skip do
  include_context "with an agent"

  let(:email) { create(:support_email, origin, ticket: support_case, subject: "VAT Certificate - #{support_case.ref}") }
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

  context "when there is an email from the supplier" do
    before do
      allow(Email).to receive(:cache_message).and_return(double.as_null_object)
      allow(MicrosoftGraph).to receive(:client).and_return(double.as_null_object)
    end

    describe "allows agent to forward that email", :with_csrf_protection do
      before do
        template = create(:support_email_template, title: "VAT forms", subject: "VAT Certificate", body: "VAT body")
        create(:support_email_template_attachment, template:)

        click_link "Messages"
        within("#messages-frame") { click_link "View" }
      end

      context "with a signatory template" do
        before do
          click_on "Forward with signature"
        end

        it "shows the recipients text boxes" do
          expect(page).to have_text "Enter an email subject"
          expect(page).to have_text "Add recipients to the email"
        end

        it "has subject text and value with Fw:" do
          expect(find("input.subject-input").value).to eq("Fw: #{email.subject}")
        end
      end
    end
  end
end
