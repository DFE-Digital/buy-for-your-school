RSpec.feature "Contentful Exceptions" do
  before { user_is_signed_in }

  context "when Contentful entry model wasn't an expected type" do
    scenario "returns an error message" do
      # TODO: setup with factory
      start_journey_from_category(category: "unexpected-contentful-type.json")

      expect(page).to have_current_path "/journeys"
      expect(find("h1.govuk-heading-xl")).to have_text "An unexpected error occurred"
      expect(find("p.govuk-body")).to have_text "The service has had a problem trying to retrieve the required step. The team have been notified of this problem and you should be able to retry shortly."
    end
  end

  context "when the Contentful Entry wasn't an expected question_types type" do
    scenario "returns an error message" do
      # TODO: setup with factory
      start_journey_from_category(category: "unexpected-contentful-question-type.json")

      expect(page).to have_current_path "/journeys"
      expect(find("h1.govuk-heading-xl")).to have_text "An unexpected error occurred"
      expect(find("p.govuk-body")).to have_text "The service has had a problem trying to retrieve the required step. The team have been notified of this problem and you should be able to retry shortly."
    end
  end

  context "when the starting entry id doesn't exist" do
    scenario "a Contentful entry_id does not exist" do
      # TODO: setup with factory
      allow(stub_client).to receive(:by_id).with("contentful-category-entry").and_return(nil)

      category = create(:category, contentful_id: "contentful-category-entry")

      user_signs_in_and_starts_the_journey(category.id)

      expect(page).to have_content("An unexpected error occurred")
      expect(page).to have_content("The service has had a problem trying to retrieve the required step. The team have been notified of this problem and you should be able to retry shortly.")
    end
  end

  context "when the Liquid template was invalid" do
    it "raises an error" do
      # TODO: setup with factory
      start_journey_from_category(category: "category-with-invalid-liquid-template.json")

      expect(page).to have_content("An unexpected error occurred")
      expect(page).to have_content("The service has had a problem trying to retrieve a working Specification template. The team have been notified of this problem and you should be able to retry shortly.")
    end
  end
end
