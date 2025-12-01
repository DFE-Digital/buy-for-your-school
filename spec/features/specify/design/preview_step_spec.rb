RSpec.feature "Content Designers can preview a journey step" do
  before do
    stub_contentful_entry(
      entry_id: "radio-question",
      fixture_filename: "steps/radio-question.json",
    )

    user_is_signed_in(user: designer_1)

    visit "/preview/entries/radio-question"
  end

  let(:designer_1) { create(:user) }

  it "redirects to the step" do
    expect(page).to have_a_step_path
  end

  it "displays the appropriate step" do
    expect(find("legend.govuk-fieldset__legend--l")).to have_text "Which service do you need?"
    expect(find(".govuk-hint p")).to have_text "Tell us which service you need."

    labels = find_all("label.govuk-radios__label")
    expect(labels[0]).to have_text "Catering"
    expect(labels[1]).to have_text "Cleaning"
  end

  it "renders a banner stating the step is a preview" do
    expect(find("h2.govuk-notification-banner__title")).to have_text "Preview"
    expect(find("h3.govuk-notification-banner__heading")).to have_text "This is a preview"
  end

  it "does not render the preview journey in the designer's dashboard" do
    visit "/dashboard"

    expect(find("h1.govuk-heading-xl")).to have_text "Specifications dashboard"
    expect(page).not_to have_content "Date started"
    expect(page).not_to have_content "Designer Preview Category"
  end

  context "when another designer previews a step" do
    let(:designer_2) { create(:user) }

    before do
      user_is_signed_in(user: designer_2)

      visit "/preview/entries/radio-question"
    end

    it "creates a new preview journey for that user" do
      expect(find("legend.govuk-fieldset__legend--l")).to have_text "Which service do you need?"
      expect(find("h2.govuk-notification-banner__title")).to have_text "Preview"
      expect(designer_1.journeys.count).to be 1
      expect(designer_2.journeys.count).to be 1
    end
  end
end
