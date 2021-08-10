RSpec.feature "short text" do
  let(:user) { create(:user) }
  let(:fixture) { "short-text-question.json" }

  before do
    user_is_signed_in(user: user)
    # TODO: setup with factory
    start_journey_from_category(category: fixture)
    click_first_link_in_section_list
  end

  context "when the step is of type short_text" do
    scenario "user can answer using free text" do
      fill_in "answer[response]", with: "email@example.com"
      click_continue

      click_first_link_in_section_list

      # /journeys/302e58f4-01b3-469a-906e-db6991184699/steps/46005bbe-1aa2-49bf-b0df-0f027522f50d/edit
      expect(page).to have_current_path %r{/journeys/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})/steps/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})/edit}
      expect(find_field("answer-response-field").value).to eql("email@example.com")
    end
  end
end
