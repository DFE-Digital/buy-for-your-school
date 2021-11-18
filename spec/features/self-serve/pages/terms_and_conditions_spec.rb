RSpec.feature "Terms and Conditions" do
  before do
    Page.create!(
      title: "Terms and conditions",
      slug: "terms_and_conditions",
      body: Rails.root.join("config/static/terms_and_conditions.md").read,
    )

    visit "/terms-and-conditions"
  end

  xdescribe "body" do
    scenario "contains the expected terms and conditions content" do
      expect(page).to have_title "Terms and conditions"
      expect(page).to have_text "Terms and conditions"
    end
  end
end
