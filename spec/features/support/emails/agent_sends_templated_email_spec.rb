describe "Support agent sends a templated email" do
  include_context "with an agent"
  include_context "with notify email templates"

  let(:support_case) { create(:support_case, :opened) }

  let(:preview_email) do
    {
      personalisation: {
        first_name: "School",
        last_name: "Contact",
        from_name: "Procurement Specialist",
        reference: "000001",
      },
    }
  end

  let(:api_preview_response) do
    {
      body: "Hi School Contact, here is information regarding frameworks",
      subject: "DfE Get help buying for schools: your request for advice and guidance",
    }
  end

  before do
    stub_request(:post, "https://api.notifications.service.gov.uk/v2/template/f4696e59-8d89-4ac5-84ca-17293b79c337/preview")
    .with(body: preview_email)
    .to_return(body: api_preview_response.to_json, status: 200, headers: {})

    visit support_case_path(support_case)
    click_link "Send template email"
  end

  describe "list of templates" do
    it "displays all available email templates to choose from" do
      # support.case_email_templates.index.what_is_a_framework.link_text
      expect(page).to have_link "What is a framework?",
                                href: "/support/cases/#{support_case.id}/email/content/f4696e59-8d89-4ac5-84ca-17293b79c337"

      # support.case_email_templates.index.how_to_approach_suppliers.link_text
      expect(page).to have_link "How to approach suppliers",
                                href: "/support/cases/#{support_case.id}/email/content/6c76ed8c-030e-4c69-8f25-ea0c66091bc5"

      # support.case_email_templates.index.catering_frameworks.link_text
      expect(page).to have_link "Catering frameworks",
                                href: "/support/cases/#{support_case.id}/email/content/12430165-4ae7-47aa-baa3-d0b3c5440a9b"

      # support.case_email_templates.index.social_value.link_text
      expect(page).to have_link "Social value",
                                href: "/support/cases/#{support_case.id}/email/content/bb4e6925-3491-44b8-8747-bdbb31257403"

      # support.case_email_templates.index.user_research.link_text
      expect(page).to have_link "Ask schools to take part in user research",
                                href: "/support/cases/#{support_case.id}/email/content/fd89b69e-7ff9-4b73-b4c4-d8c1d7b93779"
    end
  end

  describe "selecting a template" do
    before do
      click_link "What is a framework?"
    end

    it "previews the email with variables substituted" do
      within ".email-preview" do
        expect(page).to have_content "Hi School Contact, here is information regarding frameworks"
      end
    end
  end

  describe "sending the email" do
    let(:email) do
      {
        email_address: "school@email.co.uk",
        template_id: "f4696e59-8d89-4ac5-84ca-17293b79c337",
        reference: "000001",
        personalisation: {
          reference: "000001",
          first_name: "School",
          last_name: "Contact",
          email: "school@email.co.uk",
          from_name: "Procurement Specialist",
        },
      }
    end

    before do
      stub_request(:post, "https://api.notifications.service.gov.uk/v2/notifications/email")
      .with(body: email.to_json)
      .to_return(body: {}.to_json, status: 200, headers: {})

      click_link "What is a framework?"
    end

    it "saves the email as a case interaction" do
      expect(Rollbar).to receive(:info).with("Sending email to school")

      click_button "Confirm and send email"

      interacton = support_case.reload.interactions.last

      expect(interacton.event_type).to eq "email_to_school"
      expect(interacton.body).to eq "<p>Hi School Contact, here is information regarding frameworks</p>\n"
      expect(interacton.agent).to eq agent
    end
  end
end
