# FIXME: bullet sometimes alerts you to an unoptimised query due to eager loading on Support::Case
# in the SupportCase controller. This should be fixed at some point, but for now we just need to test
# the functionality of the pagination.
RSpec.feature "Case management dashboard pagination" do
  include_context "with an agent"

  describe "#my-cases" do
    before do
      create_list(:support_case, 15, agent:)
      visit "/support/cases#my-cases"
    end

    it "shows the pagination info" do
      within "#my-cases" do
        expect(all(".case-list li").count).to eq(10)
        expect(page).to have_text "Showing 1 to 10 of 15 results"
      end
    end

    it "changes to a different page when a new page link is clicked" do
      within "#my-cases" do
        find("a", text: "Next").click
        expect(page).to have_text "Showing 11 to 15 of 15 results"
      end
    end
  end

  describe "#all-cases" do
    before do
      create_list(:support_case, 20)
      create_list(:support_case, 15, agent:)
      visit "/support/cases#all-cases"
    end

    it "shows the pagination info" do
      within "#all-cases" do
        expect(all(".case-list li").count).to eq(10)
        expect(page).to have_text "Showing 1 to 10 of 35 results"
      end
    end

    it "changes to a different page when a new page link is clicked" do
      within "#all-cases" do
        find("a", text: "Next").click
        expect(page).to have_text "Showing 11 to 20 of 35 results"
      end
    end
  end

  describe "#new-cases" do
    before do
      create_list(:support_case, 20)
      create_list(:support_case, 15, agent:)
      visit "/support/cases#new-cases"
    end

    it "shows the pagination info" do
      within "#new-cases" do
        expect(all(".case-list li").count).to eq(10)
        expect(page).to have_text "Showing 1 to 10 of 35 results"
      end
    end

    it "changes to a different page when a new page link is clicked" do
      within "#new-cases" do
        find("a", text: "Next").click
        expect(page).to have_text "Showing 11 to 20 of 35 results"
      end
    end
  end
end
