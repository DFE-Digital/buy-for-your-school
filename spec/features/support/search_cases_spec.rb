RSpec.feature "Search cases", bullet: :skip do
  include_context "with an agent"

  before do
    create_list(:support_case, 10)
    visit "/support/cases/find-a-case/new"
  end

  describe "Back link" do
    it_behaves_like "breadcrumb_back_link" do
      let(:url) { "/support/cases" }
    end
  end

  it "shows the find a case heading" do
    expect(find("label.govuk-label--l")).to have_text "Find a case"
  end

  context "when searching with less than 2 characters" do
    it "validates the search term" do
      fill_in "search_case_form[search_term]", with: "1"
      click_on "Search"

      within "p.govuk-error-message" do
        expect(page).to have_text "Search term must be at least 2 characters"
      end
    end
  end

  context "when search term contains spaces" do
    it "validates the search term" do
      fill_in "search_case_form[search_term]", with: "Example Search"
      click_on "Search"

      within(all("h1.govuk-heading-l")[0]) do
        expect(page).to have_text "Search result"
      end
    end
  end
end
