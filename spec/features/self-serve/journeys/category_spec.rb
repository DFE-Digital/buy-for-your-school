RSpec.feature "A journey page has" do
  before do
    contentful_category = stub_contentful_category(fixture_filename: "#{fixture}.json")
    category = persist_category(contentful_category)
    user_exists_in_dfe_sign_in

    # landing page
    visit "/"
    # DfE sign in
    click_start
    # new journey
    click_create
    # choose category
    find("label", text: category.title).click
    # begin
    click_continue
  end

  context "when the category is 'catering'" do
    let(:fixture) { "radio-question" }

    specify "breadcrumbs" do
      expect(page).to have_breadcrumbs ["Dashboard", "Create specification"]
    end

    specify do
      expect(page).to have_a_journey_path
    end

    specify do
      expect(page).to have_title "Catering"
    end

    # specifying.start_page.page_title
    specify "heading" do
      expect(find("h1.govuk-heading-xl")).to have_text "Create a specification to procure catering for your school"
    end

    specify do
      # journeys_body
      expect(find("p.govuk-body")).to have_text "Answer all questions in each section to create a specification to share with suppliers. You can work through the sections in any order, and come back to questions later by skipping those you can't answer yet. View your specification at any time."
    end
  end

  context "when the category is 'MFDs'" do
    let(:fixture) { "mfd-radio-question" }

    specify "breadcrumbs" do
      expect(page).to have_breadcrumbs ["Dashboard", "Create specification"]
    end

    specify do
      expect(page).to have_a_journey_path
    end

    specify do
      expect(page).to have_title "Multi-function devices"
    end

    # specifying.start_page.page_title
    specify "heading" do
      expect(find("h1.govuk-heading-xl")).to have_text "Create a specification to procure multi-function devices for your school"
    end

    specify do
      # journeys_body
      expect(find("p.govuk-body")).to have_text "Answer all questions in each section to create a specification to share with suppliers. You can work through the sections in any order, and come back to questions later by skipping those you can't answer yet. View your specification at any time."
    end
  end
end
