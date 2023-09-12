require "rails_helper"

describe "Agent can browse provider contacts", js: true do
  include_context "with a framework evaluation agent"

  before do
    abc_provider = create(:frameworks_provider, short_name: "ABC")
    xyz_provider = create(:frameworks_provider, short_name: "XYZ")
    create(:frameworks_provider_contact, name: "Anne Abelle", email: "anne.abelle@email.com", provider: abc_provider)
    create(:frameworks_provider_contact, name: "Gerald Dean", email: "gerald.dean@email.com", provider: xyz_provider)
    create(:frameworks_provider_contact, name: "Val Luree", email: "val.luree@email.com", provider: xyz_provider)
  end

  it "lists all contacts" do
    visit frameworks_root_path
    click_on "Provider Contacts"
    expect(page).to have_summary("Name", "Anne Abelle")
    expect(page).to have_summary("Email", "anne.abelle@email.com")
    expect(page).to have_summary("Name", "Gerald Dean")
    expect(page).to have_summary("Email", "gerald.dean@email.com")
    expect(page).to have_summary("Name", "Val Luree")
    expect(page).to have_summary("Email", "val.luree@email.com")
  end

  describe "filtering of contacts" do
    it "can do filtering of contacts" do
      visit frameworks_root_path
      click_on "Provider Contacts"
      within "#provider-contacts .filters-panel" do
        check "ABC"
      end
      expect(page).to have_summary("Name", "Anne Abelle")
      expect(page).to have_summary("Email", "anne.abelle@email.com")
      expect(page).not_to have_summary("Name", "Gerald Dean")
      expect(page).not_to have_summary("Email", "gerald.dean@email.com")
      expect(page).not_to have_summary("Name", "Val Luree")
      expect(page).not_to have_summary("Email", "val.luree@email.com")
    end
  end

  describe "editing of a contact" do
    it "can edit a contacts detials" do
      visit frameworks_root_path
      click_on "Provider Contacts"
      click_on "Anne Abelle"
      click_on "Edit Contact"
      fill_in "Phone", with: "0114123456"
      click_on "Save changes"
      expect(page).to have_summary("Phone", "0114123456")
    end
  end
end
