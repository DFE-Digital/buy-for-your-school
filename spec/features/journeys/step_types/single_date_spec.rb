RSpec.feature "single date" do
  let(:user) { create(:user) }
  let(:fixture) { "single-date-question.json" }

  before do
    user_is_signed_in(user: user)
    # TODO: setup with factory
    start_journey_from_category(category: fixture)
    click_first_link_in_section_list
  end

  context "when the step is of type single date" do
    scenario "user can answer using a date input" do
      fill_in "answer[response(3i)]", with: "12"
      fill_in "answer[response(2i)]", with: "8"
      fill_in "answer[response(1i)]", with: "2020"

      click_continue

      click_first_link_in_section_list

      # /journeys/302e58f4-01b3-469a-906e-db6991184699/steps/46005bbe-1aa2-49bf-b0df-0f027522f50d/edit
      expect(page).to have_an_edit_step_path
      expect(find_field("answer_response_3i").value).to eql("12")
      expect(find_field("answer_response_2i").value).to eql("8")
      expect(find_field("answer_response_1i").value).to eql("2020")
    end

    scenario "date validations" do
      fill_in "answer[response(3i)]", with: "2"
      fill_in "answer[response(2i)]", with: "0"
      fill_in "answer[response(1i)]", with: "0"

      click_continue

      # /journeys/302e58f4-01b3-469a-906e-db6991184699/steps/46005bbe-1aa2-49bf-b0df-0f027522f50d/answers
      expect(page).to have_an_answer_path
      expect(page).to have_content("Provide a real date for this answer")
    end
  end
end
