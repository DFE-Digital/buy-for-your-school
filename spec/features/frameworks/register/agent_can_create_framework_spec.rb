require "rails_helper"

describe "Agent can create frameworks", :js do
  include_context "with a framework evaluation agent"

  before do
    provider = create(:frameworks_provider, short_name: "ABC")
    create(:frameworks_provider_contact, name: "Anne Abelle", email: "anne.abelle@email.com", provider:)
    create(:support_agent, first_name: "ProcOps", last_name: "User", roles: %w[procops])
    create(:support_agent, first_name: "E&O", last_name: "User", roles: %w[e_and_o])
  end

  it "creates and takes you to the new framework" do
    visit frameworks_root_path
    click_on "Add Framework"
    fill_in "Name", with: "New Framework 1"
    fill_in "Providers URL", with: "https://localhost:3000/nf1"
    fill_in "Provider reference", with: "abcnf1"
    select "ABC", from: "Provider"
    select "Anne Abelle (anne.abelle@email.com)", from: "Provider framework owner"
    within "fieldset", text: "DfE Ownership" do
      select "ProcOps User", from: "Procurement Operations Lead"
    end
    within "fieldset", text: "Availability" do
      within "fieldset", text: "Provider end date" do
        fill_in "Day", with: "04"
        fill_in "Month", with: "05"
        fill_in "Year", with: "2025"
      end
      within "fieldset", text: "DfE review date" do
        fill_in "Day", with: "02"
        fill_in "Month", with: "03"
        fill_in "Year", with: "2025"
      end
      within "fieldset", text: "Provider start date" do
        fill_in "Day", with: "03"
        fill_in "Month", with: "04"
        fill_in "Year", with: "2024"
      end
    end
    within "fieldset", text: "Other" do
      within "fieldset", text: "Is this framework a DPS (Dynamic purchasing system)?" do
        choose "Yes"
      end
      within "fieldset", text: "Is this framework a single or multi lot?" do
        choose "Multi-lot"
      end
      within "fieldset", text: "Status" do
        choose "Not approved"
      end
    end
    click_on "Create framework"

    expect(page).to have_css(".govuk-caption-l", text: "[F1] Framework")
    expect(page).to have_css(".govuk-heading-l", text: "New Framework 1")
    expect(page).to have_css(".govuk-tag", text: "Not approved")

    expect(page).to have_summary("URL", "https://localhost:3000/nf1")

    expect(page).to have_summary("Procurement Operations Lead", "ProcOps User")

    expect(page).to have_summary("Provider start date", "03/04/2024")
    expect(page).to have_summary("Provider end date", "04/05/2025")
    expect(page).to have_summary("DfE review date", "02/03/2025")

    click_on "Provider"
    expect(page).to have_summary("Provider", "ABC")
    expect(page).to have_summary("Provider Reference", "abcnf1")
    expect(page).to have_summary("Provider Framework Owner", "Anne Abelle")
    expect(page).to have_summary("Email", "anne.abelle@email.com")
  end
end
