RSpec.feature "Privacy" do
  before do
    Page.create!(
      title: "Privacy",
      slug: "privacy_notice",
      body: Rails.root.join("config/static/privacy_notice.md").read,
    )

    visit "/privacy"
  end

  describe "body" do
    scenario "contains the expected privacy content" do
      expect(page).to have_text("Privacy notice")
      expect(page).to have_title("Privacy")
    end
  end
end
