RSpec.feature "Text Question" do
  subject(:answer) { find_field("answer-response-field").value }

  before do
    user_is_signed_in
  end

  # TODO: add failed validation context
  describe "short_text" do
    scenario "user can answer using free text" do
      start_journey_from_category(category: "short-text-question.json")
      click_first_link_in_section_list

      fill_in "answer[response]", with: "email@example.com"
      click_continue

      click_first_link_in_section_list

      expect(answer).to eql "email@example.com"
    end
  end

  # TODO: add failed validation context
  describe "long_text" do
    scenario "user can answer using free text with multiple lines" do
      start_journey_from_category(category: "long-text-question.json")
      click_first_link_in_section_list

      fill_in "answer[response]", with: "We would like a supplier to provide catering from September 2020.\nThey must be able to supply us for 3 years minimum."
      click_continue

      click_first_link_in_section_list

      expect(answer).to eql "We would like a supplier to provide catering from September 2020.\r\nThey must be able to supply us for 3 years minimum."
    end
  end
end
