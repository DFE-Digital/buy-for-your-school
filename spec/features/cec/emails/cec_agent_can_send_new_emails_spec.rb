describe "Agent can send new emails", :js do
  include_context "with a cec agent"

  let(:support_case) { create(:support_case, email: "contact@email.com") }

  before do
    visit cec_onboarding_case_path(support_case)
    click_on "Messages"
  end

  it "shows the new thread expandable details button" do
    within(all("details.govuk-details")[0]) do
      expect(find("span.govuk-details__summary-text")).to have_text "Create a new message thread"
    end
  end

  describe "check CEC filter applies", :js, :with_csrf_protection do
    before do
      cec_group = create(:support_email_template_group, title: "CEC")
      create(:support_email_template_group, title: "DfE Energy for Schools service", parent: cec_group)
      template = create(:support_email_template, title: "CEC template", subject: "about cec", body: "cec body", group: cec_group)
      create(:support_email_template_attachment, template:)

      first("span", text: "Create a new message thread").click
    end

    context "with a cec template" do
      before do
        within(all("details.govuk-details")[0]) do
          click_on "Create with an email template"
        end
      end

      it "pre-selected group" do
        expect(page).to have_select("Select group", selected: "CEC")
      end
    end
  end
end
