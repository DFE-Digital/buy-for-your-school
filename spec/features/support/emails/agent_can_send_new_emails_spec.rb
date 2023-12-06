describe "Agent can send new emails", js: true do
  include_context "with an agent"

  let(:support_case) { create(:support_case, email: "contact@email.com") }

  before do
    visit support_case_path(support_case)
    click_on "Messages"
  end

  it "shows the new thread button" do
    expect(page).to have_link "Create a new message thread"
  end

  describe "creating a new thread", :with_csrf_protection, js: true do
    before do
      template = create(:support_email_template, title: "Energy template", subject: "about energy", body: "energy body")
      create(:support_email_template_attachment, template:)

      click_link "Create a new message thread"
    end

    context "with a signatory template" do
      before do
        click_on "Use signatory template"

        to_input = find("input[name$='[to]']")
        to_input.fill_in with: "to@email.com"
        to_add_button = find("button[data-input-field$='[to]']")
        to_add_button.click

        click_on "Show BCC"
        click_on "Show CC"
        sleep 0.2

        bcc_input = find("input[name$='[bcc]']")
        bcc_input.fill_in with: "bcc@email.com"
        bcc_add_button = find("button[data-input-field$='[bcc]']")
        bcc_add_button.click

        cc_input = find("input[name$='[cc]']")
        cc_input.fill_in with: "cc@email.com"
        cc_add_button = find("button[data-input-field$='[cc]']")
        cc_add_button.click
      end

      it "pre-fills the default subject line" do
        expect(page).to have_field "Enter an email subject", with: "Case 000001 – DfE Get help buying for schools: your request for advice and guidance"
      end

      it "shows added recipients", flaky: true do
        to_table = find("table[data-row-label='TO']")
        within(to_table) do
          # case email added by default
          expect(page).to have_text "contact@email.com"
          expect(page).to have_text "to@email.com"
        end

        cc_table = find("table[data-row-label='CC']")
        within(cc_table) do
          expect(page).to have_text "cc@email.com"
        end

        bcc_table = find("table[data-row-label='BCC']")
        within(bcc_table) do
          expect(page).to have_text "bcc@email.com"
        end
      end
    end

    context "with a selected template" do
      before do
        choose "Energy template"
        click_on "Use selected template"
      end

      it "pre-fills the template subject line" do
        expect(page).to have_field "Enter an email subject", with: "Case 000001 - about energy"
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
