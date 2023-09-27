require "rails_helper"

describe "Agent can set case contact details", js: true do
  include_context "with an agent"

  let(:support_case) do
    create(:support_case,
           first_name: "Contact",
           last_name: "Details",
           email: "email@address.com",
           phone_number: "07999999999")
  end

  before do
    visit support_case_path(support_case)
  end

  describe "entering new contact details" do
    before do
      update_case_contact_details(
        first_name: "New",
        last_name: "Name",
        phone: "07888666555",
        email: "new@name.com",
        extension_number: "6182",
      )
    end

    specify "saves them onto the case" do
      support_case.reload
      expect(support_case.first_name).to eq("New")
      expect(support_case.last_name).to eq("Name")
      expect(support_case.email).to eq("new@name.com")
      expect(support_case.phone_number).to eq("07888666555")
      expect(support_case.extension_number).to eq("6182")
    end
  end

  describe "leaving the email blank" do
    before do
      update_case_contact_details(
        first_name: "New",
        last_name: "Name",
        phone: "07888666555",
        email: "",
        extension_number: "6182",
      )
    end

    specify "leaves the case contact details unchanged" do
      support_case.reload
      expect(support_case.first_name).to eq("Contact")
      expect(support_case.last_name).to eq("Details")
      expect(support_case.email).to eq("email@address.com")
      expect(support_case.phone_number).to eq("07999999999")
    end
  end

  def update_case_contact_details(first_name:, last_name:, phone:, email:, extension_number:)
    within "#school-details .govuk-summary-list__row", text: "Contact name" do
      click_link "Change"
    end

    fill_in "First name", with: first_name
    fill_in "Last name", with: last_name
    fill_in "Phone number", with: phone
    fill_in "Email address", with: email
    fill_in "Extension number", with: extension_number
    click_button "Save changes"
  end
end
