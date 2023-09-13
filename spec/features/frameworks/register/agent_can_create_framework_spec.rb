require "rails_helper"

describe "Agent can create frameworks", js: true do
  include_context "with a framework evaluation agent"

  before do
    provider = create(:frameworks_provider, short_name: "ABC")
    create(:frameworks_provider_contact, name: "Anne Abelle", email: "anne.abelle@email.com", provider:)
  end

  it "creates and takes you to the new framework" do
    visit frameworks_root_path
    click_on "Add Framework"
    fill_in "Name", with: "New Framework 1"
    fill_in "Abbreviated name", with: "NF1"
    fill_in "Providers URL", with: "https://localhost:3000/nf1"
    fill_in "Providers reference", with: "abcnf1"
    select "ABC", from: "Provider"
    select "Anne Abelle (anne.abelle@email.com)", from: "Provider contact"
    within "fieldset", text: "Availability" do
      within "fieldset", text: "DfE start date" do
        fill_in "Day", with: "01"
        fill_in "Month", with: "02"
        fill_in "Year", with: "1993"
      end
      within "fieldset", text: "DfE end date" do
        fill_in "Day", with: "02"
        fill_in "Month", with: "03"
        fill_in "Year", with: "1994"
      end
      within "fieldset", text: "Provider start date" do
        fill_in "Day", with: "03"
        fill_in "Month", with: "04"
        fill_in "Year", with: "1995"
      end
      within "fieldset", text: "Provider end date" do
        fill_in "Day", with: "04"
        fill_in "Month", with: "05"
        fill_in "Year", with: "1996"
      end
    end
    within "fieldset", text: "Other" do
      within "fieldset", text: "Is this framework a DPS (Dynamic purchasing system)?" do
        choose "Yes"
      end
      within "fieldset", text: "Is this framework a single or multi lot?" do
        choose "Multi-lot"
      end
      within "fieldset", text: "Approval Status" do
        choose "Evaluating"
      end
    end
    click_on "Create framework"

    expect(page).to have_css(".govuk-heading-l", text: "New Framework 1")
    expect(page).to have_css(".govuk-tag", text: "Evaluating")
    expect(page).to have_summary("Url", "https://localhost:3000/nf1")
    expect(page).to have_summary("Provider start date", "03/04/1995")
    expect(page).to have_summary("Provider End Date", "04/05/1996")
    expect(page).to have_summary("DfE Start Date", "01/02/1993")
    expect(page).to have_summary("DfE End Date", "02/03/1994")
    click_on "Provider"
    expect(page).to have_summary("Provider", "ABC")
    expect(page).to have_summary("Framework Owner", "Anne Abelle")
    expect(page).to have_summary("Email", "anne.abelle@email.com")
  end
end
