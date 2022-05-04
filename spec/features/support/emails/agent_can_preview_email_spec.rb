describe "Agent can preview and edit a reply before sending it" do
  include_context "with an agent"

  let(:email) { create(:support_email, :inbox, case: support_case) }
  let(:support_case) { create(:support_case) }

  before do
    create(:support_interaction, :email_from_school,
           body: email.body,
           additional_data: { email_id: email.id },
           case: support_case)

    click_button "Agent Login"
    visit support_case_path(support_case)
  end

  context "when sending a reply" do
    before do
      within("#messages") do
        find("span", text: "Reply to message").click
        fill_in "message_reply_form[body]", with: "This is a test reply"
        click_button "Preview and send"
      end
    end

    it "previews the reply" do
      expect(page).to have_text "school@email.co.uk"
      expect(page).to have_text "This is a test reply"
      expect(page).to have_text "RegardsProcurement SpecialistProcurement SpecialistGet help buying for schools"
    end

    it "allows to edit the reply" do
      click_button "Edit"
      fill_in "Enter reply body", with: "Updated reply"
      click_button "Preview reply"

      expect(page).to have_text "school@email.co.uk"
      expect(page).to have_text "Updated reply"
      expect(page).to have_text "RegardsProcurement SpecialistProcurement SpecialistGet help buying for schools"
    end
  end
end
