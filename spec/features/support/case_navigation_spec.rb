RSpec.feature "Case list navigation", bullet: :skip do
  include_context "with an agent"

  before do
    category = create(:support_category, :fixed_title)
    create_list(:support_case, 13, category:)
    visit support_root_path
  end

  context "when navigating to a case with pagination and filters applied" do
    context "when using search" do
      before do
        within "#all-cases" do
          click_on "Filter results"
          select "Example Category", from: "Filter by sub-category"
          click_on "Apply filter"
          click_on "Next"
          click_on "000001"
        end
      end

      it "has a back link to the previous page" do
        click_on "Back"
        within "#all-cases" do
          expect(page).to have_select "Filter by sub-category", selected: "Example Category"
          expect(page).to have_selector "em", text: "2", class: "current"
          expect(page).to have_text "Showing 11 to 13 of 13 results"
        end
      end
    end

    context "when browsing cases" do
      before do
        click_on "All cases"
        within "#all-cases" do
          click_on "000013"
        end
      end

      it "has a back link to the previous page" do
        click_on "Back"
        expect(URI(current_url).fragment).to eq "all-cases"
      end
    end
  end
end
