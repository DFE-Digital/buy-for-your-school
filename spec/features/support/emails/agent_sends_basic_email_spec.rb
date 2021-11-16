describe "Support agent sends a basic email" do
  include_context "with an agent"

  let(:default_email_body) do
    "Thank you for getting in touch with the Get Help Buying For Schools team, and thank you for using our online service to create your catering specification."
  end

  let(:support_case) { create(:support_case, :open) }

  before do
    click_button "Agent Login"
    visit support_case_path(support_case)
    click_link "Send email"
  end

  describe "selecting a non-template email" do
    before do
      choose "Non-template"
      click_button "Save"
    end

    it "provides the user with a basic email body to customise" do
      expect(page).to have_field "Enter email body", text: default_email_body
    end
  end

  describe "customisating the email body" do
    let(:custom_email_body) { "New email body" }

    before do
      choose "Non-template"
      click_button "Save"
      fill_in "Enter email body", with: custom_email_body
      click_button "Preview email"
    end

    it "shows the new email body on the preview screen" do
      within ".email-preview-body" do
        expect(page).to have_content "New email body"
      end
    end

    context "when leaving the email body blank" do
      let(:custom_email_body) { "" }

      it "displays an error" do
        within ".govuk-form-group--error" do
          expect(page).to have_content "Please enter an email body to be sent"
        end
      end
    end
  end

  describe "previewing the email body" do
    before do
      choose "Non-template"
      click_button "Save"
      click_button "Preview email"
    end

    it "shows the email body" do
      within ".email-preview-body" do
        expect(page).to have_content(default_email_body)
      end
    end

    it "shows the correct subject and to address" do
      within ".email-preview" do
        expect(page).to have_content "DfE Get help buying for schools: your request for support"
        expect(page).to have_content "school@email.co.uk"
      end
    end

    describe "navigating directly to the preview" do
      before { visit support_case_email_content_path(support_case, template: :basic) }

      it "shows the email body" do
        within ".email-preview-body" do
          expect(page).to have_content(default_email_body)
        end
      end

      it "shows the correct subject and to address" do
        within ".email-preview" do
          expect(page).to have_content "DfE Get help buying for schools: your request for support"
          expect(page).to have_content "school@email.co.uk"
        end
      end
    end
  end

  describe "sending the email" do
    let(:email) do
      {
        email_address: "school@email.co.uk",
        template_id: "ac679471-8bb9-4364-a534-e87f585c46f3",
        reference: "000001",
        personalisation: {
          reference: "000001",
          first_name: "School",
          last_name: "Contact",
          email: "school@email.co.uk",
          text: "New email body",
          from_name: "Procurement Specialist",
        },
      }
    end

    before do
      stub_request(:post, "https://api.notifications.service.gov.uk/v2/notifications/email")
      .with(body: email.to_json)
      .to_return(body: {}.to_json, status: 200, headers: {})

      choose "Non-template"
      click_button "Save"
      fill_in "Enter email body", with: "New email body"
      click_button "Preview email"
    end

    it "saves the email as a case interaction" do
      expect(Rollbar).to receive(:info).with("Sending email to school")

      click_button "Confirm and send email"

      interacton = support_case.reload.interactions.last

      expect(interacton.event_type).to eq "email_to_school"
      expect(interacton.body).to eq "New email body"
      expect(interacton.agent).to eq agent
    end
  end
end
