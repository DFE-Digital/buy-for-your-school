feature "Users can preview a journey step" do
  context "when the user is on the preview environment" do
    around do |example|
      ClimateControl.modify(CONTENTFUL_PREVIEW_APP: "true") do
        example.run
      end
    end

    scenario "the appropriate step is displayed" do
      stub_contentful_entry(
        entry_id: "radio-question",
        fixture_filename: "steps/radio-question.json",
      )

      user_is_signed_in

      visit preview_entry_path("radio-question")

      expect(page).to have_content("Which service do you need?")
      expect(page).to have_content("Catering")
      expect(page).to have_content("Cleaning")
    end
  end
end
