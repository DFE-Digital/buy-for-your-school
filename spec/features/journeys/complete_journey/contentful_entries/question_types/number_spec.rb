RSpec.feature "Contentful Entry Type: Number" do
  let(:user) { create(:user)}
  let(:fixture) { "number-question.json" }

  before do
    user_is_signed_in(user: user)
    # TODO: setup with factory
    start_journey_from_category(category: fixture)
  end

  context "when Contentful entry is of type 'numbers'" do
    scenario "user can answer using a number input" do
      click_first_link_in_section_list

      fill_in "answer[response]", with: "190"
      click_continue

      click_first_link_in_section_list


      expect(page).to have_current_path %r{/journeys/.*}
      expect(find_field("answer-response-field").value).to eql("190")
    end

    scenario "users receive an error when not entering a number" do
      click_first_link_in_section_list

      fill_in "answer[response]", with: "foo"
      click_continue

      expect(page).to have_current_path %r{/journeys/.*}
      expect(find("span.govuk-error-message")).to have_text "is not a number"
    end

    scenario "users receive an error when entering a decimal number" do
      click_first_link_in_section_list

      fill_in "answer[response]", with: "435.65"
      click_continue

      expect(page).to have_current_path %r{/journeys/.*}
      expect(find("span.govuk-error-message")).to have_text "must be an integer"
    end
  end
end
