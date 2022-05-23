describe "Support agent sends a basic email" do
  include_context "with an agent"

  let(:support_case) { create(:support_case, :opened) }

  let(:email_body) { "New email body" }

  let(:basic_template_id) { "ac679471-8bb9-4364-a534-e87f585c46f3" }

  let(:preview_email) do
    {
      personalisation: {
        first_name: "School",
        last_name: "Contact",
        text: email_body,
        from_name: "Procurement Specialist",
        reference: "000001",
      },
    }
  end

  let(:api_preview_response) do
    {
      body: "Dear School Contact\r\n\r\n#{email_body}\r\n\r\nRegards\r\nProcurement Specialist\r\nGet help buying for schools",
      subject: "DfE Get help buying for schools: your request for support",
    }
  end

  before do
    stub_request(:post, "https://api.notifications.service.gov.uk/v2/template/#{basic_template_id}/preview")
    .with(body: preview_email)
    .to_return(body: api_preview_response.to_json, status: 200, headers: {})

    click_button "Agent Login"
    visit support_case_path(support_case)
    click_link "Send email"
  end

  describe "customising the email body" do
    before do
      choose "Non-template"
      click_button "Save"
      fill_in "Enter email body", with: email_body
      click_button "Preview email"
    end

    it "shows the new email body on the preview screen" do
      within ".email-preview-body" do
        expect(page).to have_content "New email body"
      end
    end

    it "retains the updated email body when clicking back on the preview" do
      click_link "Back"
      expect(page).to have_field("Enter email body", with: "New email body")
    end

    context "when leaving the email body blank" do
      let(:email_body) { "" }

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
      fill_in "Enter email body", with: email_body
      click_button "Preview email"
    end

    it "shows the email body" do
      within ".email-preview-body" do
        expect(page).to have_content(email_body)
      end
    end

    it "shows the correct subject and to address" do
      within ".email-preview" do
        expect(page).to have_content "DfE Get help buying for schools: your request for support"
        expect(page).to have_content "school@email.co.uk"
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
          text: email_body,
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
      fill_in "Enter email body", with: email_body
      click_button "Preview email"
    end

    it "saves the email as a case interaction" do
      expect(Rollbar).to receive(:info).with("Sending email to school")

      click_button "Confirm and send email"

      interacton = support_case.reload.interactions.last

      expect(interacton.event_type).to eq "email_to_school"
      expect(interacton.body).to eq "<p>Dear School Contact</p>\n\n<p><p>#{email_body}</p></p>\n\n<p>Regards\n<br />Procurement Specialist\n<br />Get help buying for schools</p>"
      expect(interacton.agent).to eq agent
    end
  end
end
