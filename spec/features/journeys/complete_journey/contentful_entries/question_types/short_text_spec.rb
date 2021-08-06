RSpec.feature "Contentful Entry Type: Short Text" do
  before { user_is_signed_in }

  context "when Contentful entry is of type 'short_text'" do
    scenario "user can answer using free text" do
      # TODO: setup with factory
      start_journey_from_category(category: "short-text-question.json")
      click_first_link_in_section_list

      fill_in "answer[response]", with: "email@example.com"
      click_continue

      click_first_link_in_section_list

      expect(find_field("answer-response-field").value).to eql("email@example.com")
    end
  end
end
