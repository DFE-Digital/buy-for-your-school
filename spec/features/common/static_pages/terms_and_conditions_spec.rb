RSpec.feature "Terms and Conditions" do
  before do
    Page.create!(
      title: "Terms and Conditions",
      slug: "terms_and_conditions",
      body: File.read("./static/terms_and_conditions.md"),
    )
    visit "/terms-and-conditions"
  end

  describe "body" do
    scenario "contains the expected terms and conditions content" do
      expect(page).to have_text("Terms and conditions")
      expect(page).to have_title("Terms and Conditions")
    end
  end
end
