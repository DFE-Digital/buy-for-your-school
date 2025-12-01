RSpec.feature "Number Question" do
  before do
    user_is_signed_in
    start_journey_from_category(category: "number-question.json")
    click_first_link_in_section_list
  end

  describe "numbers" do
    scenario "user can answer using a number input" do
      fill_in "answer[response]", with: "190"
      click_continue

      click_first_link_in_section_list

      expect(find_field("answer-response-field").value).to eql "190"
    end

    scenario "users receive an error when not entering a number" do
      fill_in "answer[response]", with: "foo"
      click_continue

      expect(page).to have_content "is not a number"
    end

    scenario "users receive an error when entering a decimal number" do
      fill_in "answer[response]", with: "435.65"
      click_continue

      expect(page).to have_content "must be an integer"
    end
  end
end
