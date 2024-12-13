describe "Case tasklist", :js do
  include_context "with an agent"

  before do
    visit "/support/cases/#{support_case.id}#tasklist"
  end

  context "when a case is level 4 (or 5)" do
    let(:support_case) { create(:support_case, support_level: "L4") }

    it "has a tasklist tab with a tasklist and items" do
      within "#tasklist" do
        expect(page).to have_text("Procurement task list")
        expect(page).to have_text("Complete evaluation")
        expect(page).to have_css(".govuk-task-list")
        expect(page).to have_link("Add evaluators")
      end
    end

    it "navigates to the add evaluators page when clicked" do
      within "#tasklist" do
        click_link "Add evaluators"
        expect(page).to have_current_path("/support/cases/#{support_case.id}/evaluators")
      end
    end
  end
end
