RSpec.describe "Editing a specification" do
  let(:user) { create(:user) }
  let(:journey) { create(:journey, user:) }

  before do
    user_is_signed_in(user:)
    visit "/journeys/#{journey.id}"
  end

  context "when the user clicks 'Edit name'" do
    before do
      click_on "Edit name"
    end

    it "lets them change the specification name" do
      fill_in "edit_journey_form[name]", with: "Updated spec name"
      click_continue

      expect(page).to have_text "Specification name updated"
      expect(page).to have_text "You are creating: Updated spec name"
    end

    it "lets them go back to the specification" do
      click_on "Back"

      expect(page).to have_current_path "/journeys/#{journey.id}"
    end
  end
end
