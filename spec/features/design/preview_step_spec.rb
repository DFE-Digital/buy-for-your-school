RSpec.feature "Content Designers can preview a journey step" do
  before do
    # @see ContentfulHelpers
    stub_contentful_entry(
      entry_id: "radio-question",
      fixture_filename: "steps/radio-question.json",
    )

    user_is_signed_in

    # OPTIMIZE: would this endpoint be better under "/design"?
    visit "/preview/entries/radio-question"
  end

  # TODO: revisit the usefulness of the "Preview"
  xcontext "when they are NOT on the preview environment" do
    scenario "a 404 error is returned" do
      expect(find("h2.govuk-heading-xl")).to have_text "Page not found"
    end
  end

  context "when they are on the preview environment" do
    # around do |example|
    #   ClimateControl.modify(CONTENTFUL_PREVIEW_APP: "true") do
    #     example.run
    #   end
    # end

    scenario "the appropriate step is displayed" do
      expect(find("legend.govuk-fieldset__legend--l")).to have_text "Which service do you need?"
      expect(find(".govuk-hint p")).to have_text "Tell us which service you need."

      labels = find_all("label.govuk-radios__label")
      expect(labels[0]).to have_text "Catering"
      expect(labels[1]).to have_text "Cleaning"
    end
  end
end
