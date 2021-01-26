feature "Users can preview a journey step" do
  scenario "the appropriate step is displayed" do
    stub_get_contentful_entry(
      entry_id: "contentful-radio-question",
      fixture_filename: "steps/contentful-radio-question.json"
    )

    visit preview_entry_path("contentful-radio-question")

    expect(page).to have_content("Which service do you need?")
    expect(page).to have_content("Catering")
    expect(page).to have_content("Cleaning")
  end
end
