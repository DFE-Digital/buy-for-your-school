RSpec.feature "Content errors" do
  context "when the Contentful Entry model was not an expected type" do
    it "renders an error page" do
      start_journey_from_category(category: "unexpected-contentful-type.json")

      # errors.unexpected_contentful_model.page_title
      expect(find("h1.govuk-heading-xl")).to have_text "An unexpected error occurred"
      # errors.unexpected_contentful_model.page_body
      expect(find("p.govuk-body", text: "The service has had a problem trying to retrieve the required step. The team have been notified of this problem and you should be able to retry shortly.")).to be_present
    end
  end

  context "when the Contentful Question was not an expected type" do
    it "renders an error page" do
      start_journey_from_category(category: "unexpected-contentful-question-type.json")

      # errors.unexpected_contentful_step_type.page_title
      expect(find("h1.govuk-heading-xl")).to have_text "An unexpected error occurred"
      # errors.unexpected_contentful_step_type.page_body
      expect(find("p.govuk-body", text: "The service has had a problem trying to retrieve the required step. The team have been notified of this problem and you should be able to retry shortly.")).to be_present
    end
  end

  context "when the Contentful Entry does not exist" do
    it "renders an error page" do
      allow(stub_client).to receive(:by_id).with("contentful-category-entry").and_return(nil)

      create(:category, contentful_id: "contentful-category-entry", slug: "cleaning")

      user_signs_in_and_starts_the_journey("cleaning")

      # errors.contentful_entry_not_found.page_title
      expect(find("h1.govuk-heading-xl")).to have_text "An unexpected error occurred"
      # errors.contentful_entry_not_found.page_body
      expect(find("p.govuk-body", text: "The service has had a problem trying to retrieve the required step. The team have been notified of this problem and you should be able to retry shortly.")).to be_present
    end
  end

  context "when the Liquid template is invalid" do
    it "renders an error page" do
      start_journey_from_category(category: "category-with-invalid-liquid-template.json")

      # errors.specification_template_invalid.page_title
      expect(find("h1.govuk-heading-xl")).to have_text "An unexpected error occurred"
      # errors.specification_template_invalid.page_body
      expect(find("p.govuk-body", text: "The service has had a problem trying to retrieve a working Specification template. The team have been notified of this problem and you should be able to retry shortly.")).to be_present
    end
  end
end
