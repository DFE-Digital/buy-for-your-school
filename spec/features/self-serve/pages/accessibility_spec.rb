RSpec.feature "Accessibility" do
  before do
    Page.create!(
      title: "Accessibility",
      slug: "accessibility",
      body: Rails.root.join("config/static/accessibility.md").read,
    )

    visit "/accessibility"
  end

  xdescribe "body" do
    scenario "contains the expected accessibility content" do
      expect(page).to have_title "Accessibility"
      expect(page).to have_text "Accessibility statement"
    end
  end
end
