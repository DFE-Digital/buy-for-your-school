RSpec.feature "Contentful Entry Type: Single Date" do
  before { user_is_signed_in }

  context "when Contentful entry is of type 'single_date'" do
    scenario "user can answer using a date input" do
      # TODO: setup with factory
      start_journey_from_category(category: "single-date-question.json")
      click_first_link_in_section_list

      fill_in "answer[response(3i)]", with: "12"
      fill_in "answer[response(2i)]", with: "8"
      fill_in "answer[response(1i)]", with: "2020"

      click_continue

      click_first_link_in_section_list

      expect(find_field("answer_response_3i").value).to eql("12")
      expect(find_field("answer_response_2i").value).to eql("8")
      expect(find_field("answer_response_1i").value).to eql("2020")
    end

    scenario "date validations" do
      # TODO: setup with factory
      start_journey_from_category(category: "single-date-question.json")
      click_first_link_in_section_list

      fill_in "answer[response(3i)]", with: "2"
      fill_in "answer[response(2i)]", with: "0"
      fill_in "answer[response(1i)]", with: "0"

      click_continue
      expect(page).to have_content("Provide a real date for this answer")
    end
  end
end
