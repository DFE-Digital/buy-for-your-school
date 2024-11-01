require "rails_helper"

RSpec.describe "Additional Contacts", :js, type: :feature do
  include_context "with an agent"

  let(:support_case) { create(:support_case) }

  before do
    visit support_case_path(support_case)
  end

  describe "Creating an additional contact" do
    context "with valid attributes" do
      before do
        visit new_support_case_additional_contact_path(case_id: support_case.id)

        fill_in "First name", with: "John"
        fill_in "Last name", with: "Doe"
        fill_in "Email address", with: "john.doe@example.com"
        fill_in "Phone number", with: "1234567890"
        fill_in "Extension number", with: "123"
        click_button "Save changes"  # Adjust if the button text is different
      end

      specify "creates a new contact and redirects to the additional contacts index" do
        expect(page).to have_current_path(support_case_additional_contacts_path(case_id: support_case.id))
        expect(page).to have_content("Additional contact successfully created")
        expect(page).to have_content("John Doe")
      end
    end
  end

  describe "Updating an additional contact" do
    let(:additional_contact) { create(:support_case_additional_contact, support_case_id: support_case.id) }

    context "with valid attributes" do
      before do
        visit edit_support_case_additional_contact_path(case_id: support_case.id, id: additional_contact.id)

        fill_in "First name", with: "Jane"
        fill_in "Last name", with: "Smith"
        fill_in "Email address", with: "jane.smith@example.com"
        fill_in "Phone number", with: "0987654321"
        fill_in "Extension number", with: "456"
        click_button "Save changes"  # Adjust if the button text is different
      end

      specify "updates the contact and redirects to the additional contacts index" do
        expect(page).to have_current_path(support_case_additional_contacts_path(case_id: support_case.id))
        expect(page).to have_content("Additional contact successfully updated")
        expect(page).to have_content("Jane Smith")
      end
    end
  end
end
