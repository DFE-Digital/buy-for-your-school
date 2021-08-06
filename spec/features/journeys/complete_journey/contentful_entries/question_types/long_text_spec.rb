RSpec.feature "Contentful Entry Type: Long Text" do
  let(:user) { create(:user)}
  let(:fixture) { "long-text-question.json" }

  before do
    user_is_signed_in(user: user)
    # TODO: setup with factory
    start_journey_from_category(category: fixture)
  end

  context "when Contentful entry is of type 'long_text'" do
    scenario "user can answer using free text with multiple lines" do
      click_first_link_in_section_list

      fill_in "answer[response]", with: "We would like a supplier to provide catering from September 2020.\nThey must be able to supply us for 3 years minimum."
      click_continue

      click_first_link_in_section_list

      expect(page).to have_current_path %r{/journeys/.*}
      expect(find_field("answer-response-field").value).to eql("We would like a supplier to provide catering from September 2020.\r\nThey must be able to supply us for 3 years minimum.")
    end
  end
end
