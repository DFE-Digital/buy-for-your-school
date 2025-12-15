RSpec.feature "Filter cases", :js do
  include_context "with an agent"

  let(:catering_cat) { create(:support_category, title: "Catering") }
  let(:mfd_cat) { create(:support_category, title: "MFD") }

  before do
    create_list(:support_case, 10)
    create(:support_case, category: catering_cat)
    create(:support_case, category: mfd_cat, state: :on_hold)
    create(:support_case, category: mfd_cat, state: :opened)
    create(:support_case, agent:)
    create(:support_case, state: :closed)
    visit support_root_path
  end

  describe "case filtering" do
    it "filters by category" do
      click_link "All cases"
      within "#all-cases" do
        check "Catering"
        expect(all(".case-list li").count).to eq(1)
        row = all(".case-list li")
        expect(row[0]).to have_text "Catering"
      end
    end

    it "filters by agent" do
      click_link "All cases"
      within "#all-cases" do
        check agent.first_name
        expect(all(".case-list li").count).to eq(1)
        row = all(".case-list li")
        expect(row[0]).to have_text agent.first_name
      end
    end

    it "filters by state" do
      click_link "All cases"
      within "#all-cases" do
        check "Closed"
        expect(all(".case-list li").count).to eq(1)
        row = all(".case-list li")
        expect(row[0]).to have_text "Closed"
      end
    end
  end

  describe "case filtering and sorting" do
    it "filters by category and sorts by state" do
      click_link "All cases"
      within "#all-cases" do
        check "MFD"
        select "Status", from: "Sort by"
        choose "Ascending"
        expect(all(".case-list li").count).to eq(2)
        row = all(".case-list li")
        expect(row[0]).to have_text "On Hold"
      end
    end
  end
end
