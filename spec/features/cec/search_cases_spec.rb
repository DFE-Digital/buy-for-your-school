RSpec.feature "Search cases" do
  include_context "with a cec agent"
  let(:support_organisation) { create(:support_organisation, urn: 100_253, name: "Old Town Primary School") }
  let(:dfe_category) { create(:support_category, title: "DfE Energy for Schools service") }
  let(:other_category) { create(:support_category, title: "Cleaning Services") }

  before do
    create_list(:support_case, 2, category: dfe_category, organisation: support_organisation)
    create_list(:support_case, 5, category: other_category, organisation: support_organisation)
    visit cec_case_search_new_path
  end

  describe "Back link" do
    it_behaves_like "breadcrumb_back_link" do
      let(:url) { "/cec/onboarding_cases" }
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
      fill_in "search_case_form[search_term]", with: "Old Town Primary School"
      click_on "Search"

      within(all("h1.govuk-heading-l")[0]) do
        expect(page).to have_text "Search result"
      end
    end
  end

  context "when support case has energy sub category" do
    it "validates the search result count" do
      fill_in "search_case_form[search_term]", with: "Old Town Primary School"
      click_on "Search"

      expect(page).to have_text "Search result"

      rows = all("table.govuk-table tbody tr")
      expect(rows.size).to eq(2)
    end
  end
end
