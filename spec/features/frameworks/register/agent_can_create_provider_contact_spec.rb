require "rails_helper"

describe "Agent can create provider contacts", :js do
  include_context "with a framework evaluation agent"

  before do
    create(:frameworks_provider, short_name: "ABC")
  end

  it "creates and takes you to the new contact" do
    visit frameworks_root_path
    click_on "Provider Contacts"
    click_on "Add Contact"
    fill_in "Name", with: "Jane Doe"
    fill_in "Email", with: "jane.doe@educaction.gov.uk"
    fill_in "Phone", with: "0114123456"
    select "ABC", from: "Provider"
    click_on "Create contact"

    expect(page).to have_css(".govuk-heading-l", text: "Jane Doe")
    expect(page).to have_summary("Email", "jane.doe@educaction.gov.uk")
    expect(page).to have_summary("Phone", "0114123456")
    expect(page).to have_summary("Provider", "ABC")
  end
end
