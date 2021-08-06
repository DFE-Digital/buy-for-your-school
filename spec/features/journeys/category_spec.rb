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
    let(:fixture) { "radio-question_types" }

    specify "page title" do
      expect(page.title).to have_text "Catering"
    end

    # specifying.start_page.page_title
    specify "heading" do
      expect(find("h1.govuk-heading-xl")).to have_text "Create a specification to procure catering for your school"
    end
  end

  context "when the category is 'MFDs'" do
    let(:fixture) { "mfd-radio-question_types" }

    specify "page title" do
      expect(page.title).to have_text "Multi-function devices"
    end

    # specifying.start_page.page_title
    specify "heading" do
      expect(find("h1.govuk-heading-xl")).to have_text "Create a specification to procure multi-function devices for your school"
    end
  end
end
