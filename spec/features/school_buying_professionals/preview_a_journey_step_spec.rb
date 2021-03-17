feature "Users can preview a journey step" do
  scenario "the appropriate step is displayed" do
    stub_contentful_entry(
      entry_id: "radio-question",
      fixture_filename: "steps/radio-question.json"
    )

    visit preview_entry_path("radio-question")

    expect(page).to have_content("Which service do you need?")
    expect(page).to have_content("Catering")
    expect(page).to have_content("Cleaning")
  end
end
