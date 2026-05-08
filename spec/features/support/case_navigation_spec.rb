RSpec.feature "Case list navigation", :js do
  include_context "with an agent"

  let(:category) { create(:support_category, :fixed_title) }
  let!(:support_cases) { create_list(:support_case, 13, category:) }
  let(:target_case) { support_cases.first }
  let(:newest_case) { support_cases.last }

  before do
    visit support_root_path
  end

  context "when navigating to a case with pagination and filters applied" do
    context "when using search" do
      before do
        click_on "All cases"
        within "#all-cases" do
          check "Example Category"
          click_on "Next"
        end

        within "#all-cases" do
          expect(page).to have_selector("em.current", text: "2")
          expect(page).to have_text("Showing 11 to 13 of 13 results")
          click_on target_case.ref
        end
      end

      it "has a back link to the previous page" do
        click_on "Back"
        within "#all-cases" do
          expect(page).to have_checked_field "Example Category"
          expect(page).to have_selector "em", text: "2", class: "current"
          expect(page).to have_text "Showing 11 to 13 of 13 results"
        end
      end
    end

    context "when browsing cases" do
      before do
        click_on "All cases"
        within "#all-cases" do
          click_on newest_case.ref
        end
      end

      it "has a back link to the previous page" do
        click_on "Back"
        expect(URI(current_url).fragment).to eq "all-cases"
      end
    end
  end
end
