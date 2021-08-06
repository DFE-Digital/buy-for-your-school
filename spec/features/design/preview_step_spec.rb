RSpec.feature "Content Designers can preview a journey step" do
  before do
    stub_contentful_entry(
      entry_id: "radio-question_types",
      fixture_filename: "steps/radio-question_types.json",
    )

    user_is_signed_in
    visit "/preview/entries/radio-question_types"
  end

  scenario "the appropriate step is displayed" do
    expect(page).to have_current_path %r{/journeys/.*/steps/.*}

    expect(find("legend.govuk-fieldset__legend--l")).to have_text "Which service do you need?"
    expect(find(".govuk-hint p")).to have_text "Tell us which service you need."

    labels = find_all("label.govuk-radios__label")
    expect(labels[0]).to have_text "Catering"
    expect(labels[1]).to have_text "Cleaning"
  end

  scenario "a banner reminding that the step is preview is rendered" do
    expect(find("h2.govuk-notification-banner__title")).to have_text "Preview"
    expect(find("h3.govuk-notification-banner__heading")).to have_text "This is a preview"
  end
end
