require "rails_helper"

describe "Agent can browse frameworks register", js: true do
  include_context "with a framework evaluation agent"

  before do
    provider = create(:frameworks_provider, short_name: "TestProv")
    create(:frameworks_framework, reference: "books", name: "Books & Stationary")
    create(:frameworks_framework, reference: "legal", name: "Legal services", provider:)
    create(:frameworks_framework, reference: "water", name: "Water services", provider:)
  end

  it "lists all frameworks" do
    visit frameworks_root_path
    expect(page).to have_summary("Framework Ref", "books")
    expect(page).to have_summary("Framework Name", "Books & Stationary")
    expect(page).to have_summary("Framework Ref", "legal")
    expect(page).to have_summary("Framework Name", "Legal services")
    expect(page).to have_summary("Framework Ref", "water")
    expect(page).to have_summary("Framework Name", "Water services")
  end

  it "can view the details of a framework" do
    visit frameworks_root_path
    click_on "books"
    expect(page).to have_title("Books & Stationary")
  end

  describe "filtering of frameworks" do
    it "can do filtering of frameworks" do
      visit frameworks_root_path
      within "#frameworks-register .filters-panel" do
        click_on "Provider"
        check "TestProv"
      end
      expect(page).to have_summary("Framework Ref", "legal")
      expect(page).to have_summary("Framework Name", "Legal services")
      expect(page).to have_summary("Framework Ref", "water")
      expect(page).to have_summary("Framework Name", "Water services")
      expect(page).not_to have_summary("Framework Ref", "books")
      expect(page).not_to have_summary("Framework Name", "Books & Stationary")
    end
  end
end
