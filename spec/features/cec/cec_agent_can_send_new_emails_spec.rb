describe "Cec agent can send new emails", :js do
  include_context "with a cec agent"

  let(:dfe_energy_category) { create(:support_category, title: "DfE Energy for Schools service") }
  let(:support_case) { create(:support_case, category: dfe_energy_category, email: "contact@email.com") }

  before do
    create(:support_case_attachment, case: support_case, custom_name: "Classroom.pdf")
    visit cec_onboarding_case_path(support_case)
    click_on "Messages"
  end

  it "shows the new thread expandable details button" do
    within(all("details.govuk-details")[0]) do
      expect(find("span.govuk-details__summary-text")).to have_text "Create a new message thread"
    end
  end

  describe "creating a new thread", :js, :with_csrf_protection do
    before do
      first("span", text: "Create a new message thread").click
    end

    context "with a signatory template" do
      before do
        within(all("details.govuk-details")[0]) do
          click_on "Create using a signatory template"
        end

        find("input[name$='[to]']").fill_in with: "to@email.com"
        find("button[data-input-field$='[to]']").click

        click_on "Show BCC"
        click_on "Show CC"

        find("input[name$='[bcc]']").fill_in with: "bcc@email.com"
        find("button[data-input-field$='[bcc]']").click

        find("input[name$='[cc]']").fill_in with: "cc@email.com"
        find("button[data-input-field$='[cc]']").click
      end

      it "pre-fills the default subject line" do
        expect(page).to have_field "Enter an email subject", with: "Case 000001 – DfE Get help buying for schools: your request for advice and guidance"
      end

      it "shows added recipients" do
        within("table[data-row-label='TO']") do
          expect(page).to have_text "contact@email.com"
          expect(page).to have_text "to@email.com"
        end

        within("table[data-row-label='CC']") do
          expect(page).to have_text "cc@email.com"
        end

        within("table[data-row-label='BCC']") do
          expect(page).to have_text "bcc@email.com"
        end
      end

      it "has the energy team signature" do
        expect(page).to have_text "Energy for Schools Service Team"
        expect(page).to have_text "Energy for Schools disclaimer"
      end

      it "allows attachments from case files" do
        click_link "Case files"
        check "Classroom.pdf"
        click_button "Attach 1 file"

        expect(page).to have_text "Create a new message thread"
        expect(page).to have_text "Classroom.pdf"
      end
    end

    context "with a selected template" do
      before do
        template = create(:support_email_template, title: "Energy for Schools template", subject: "about efs", body: "energy body")
        create(:support_email_template_attachment, template:)

        within(all("details.govuk-details")[0]) do
          click_on "Create with an email template"
        end
        choose "Energy for Schools template"
        click_on "Use selected template"
      end

      it "pre-fills the template subject line" do
        expect(page).to have_field "Enter an email subject", with: "Case 000001 - about efs"
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
