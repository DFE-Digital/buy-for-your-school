require "rails_helper"

describe "Agent can save attachments from an email to the case", js: true do
  include_context "with an agent"

  before { click_button "Agent Login" }

  context "with email attachments on an email" do
    let!(:email) { create(:support_email, :inbox, case: support_case) }
    let!(:email_interaction) { create(:support_interaction, :email_from_school, case: support_case, additional_data: { email_id: email.id }) }
    let(:support_case) { create(:support_case) }
    let(:email_attachment1) { create(:support_email_attachment, email:) }
    let(:email_attachment2) { create(:support_email_attachment, email:) }

    describe "saving an attachment to the case" do
      before do
        email_attachment1.update!(file_name: "attachment1.txt")
        email_attachment2.update!(file_name: "attachment2.txt")

        visit support_case_path(support_case)
        click_link "Messages"
        click_link "View"

        within ".message-details" do
          click_link "Save attachments"
        end
        check "attachment1.txt"
        within ".govuk-checkboxes", text: "attachment1.txt" do
          fill_in "Rename attachment (optional)", with: "MyNewFileName"
          fill_in "Add attachment description", with: "Neat description"
        end
        check "attachment2.txt"
        within ".govuk-checkboxes", text: "attachment2.txt" do
          fill_in "Rename attachment (optional)", with: "MyOtherFileName"
          fill_in "Add attachment description", with: "Pretty good description"
        end
        click_button "Save to case"
      end

      it "displays the created case attachments with file extensions automatically added" do
        expect(page).to have_content("Attachments saved")

        within "tr", text: "MyNewFileName.txt" do
          expect(page).to have_content("Neat description")
        end

        within "tr", text: "MyOtherFileName.txt" do
          expect(page).to have_content("Pretty good description")
        end
      end
    end
  end
end
