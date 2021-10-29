RSpec.feature "Accessibility" do
  before do
    Page.create!(
      title: "Accessibility",
      slug: "accessibility",
      body: "# **Accessibility statement**",
    )
    visit "/accessibility"
  end

  describe "body" do
    scenario "contains the expected accessibility content" do
      expect(page).to have_text("Accessibility statement")
      expect(page).to have_title("Accessibility")
    end
  end
end
