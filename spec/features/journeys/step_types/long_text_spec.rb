RSpec.feature "long text" do
  let(:user) { create(:user) }
  let(:fixture) { "long-text-question.json" }

  before do
    user_is_signed_in(user: user)
    # TODO: setup with factory
    start_journey_from_category(category: fixture)
  end

  context "when the step is of type long_text" do
    scenario "user can answer using free text with multiple lines" do
      click_first_link_in_section_list

      fill_in "answer[response]", with: "We would like a supplier to provide catering from September 2020.\nThey must be able to supply us for 3 years minimum."
      click_continue

      click_first_link_in_section_list

      # /journeys/302e58f4-01b3-469a-906e-db6991184699/steps/46005bbe-1aa2-49bf-b0df-0f027522f50d/edit
      expect(page).to have_current_path %r{/journeys/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})/steps/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})/edit}
      expect(find_field("answer-response-field").value).to eql("We would like a supplier to provide catering from September 2020.\r\nThey must be able to supply us for 3 years minimum.")
    end
  end
end
