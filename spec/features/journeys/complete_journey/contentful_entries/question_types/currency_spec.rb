RSpec.feature "Contentful Entry Type: Currency" do
  before { user_is_signed_in }

  context "when Contentful entry is of type 'currency'" do
    scenario "user can answer using a currency number input" do
      # TODO: setup with factory
      start_journey_from_category(category: "currency-question.json")
      click_first_link_in_section_list

      fill_in "answer[response]", with: "1,000.01"
      click_continue

      click_first_link_in_section_list

      expect(find_field("answer-response-field").value).to eql("1000.01")
    end

    scenario "throws error when non numerical values are entered" do
      # TODO: setup with factory
      start_journey_from_category(category: "currency-question.json")
      click_first_link_in_section_list

      fill_in "answer[response]", with: "one hundred pounds"
      click_continue

      expect(page).to have_content("does not accept £ signs or other non numerical characters")
    end
  end
end
