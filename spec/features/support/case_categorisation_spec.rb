require "rails_helper"

describe "Case categorisation" do
  include_context "with an agent"

  let!(:support_case) { create(:support_case, :with_documents, category: business_services_audit) }
  let!(:business_services) { create(:support_category, title: "Business Services") }
  let!(:business_services_audit) { create(:support_category, title: "Audit", parent: business_services) }
  let!(:ict) { create(:support_category, title: "ICT") }
  let!(:ict_hardware) { create(:support_category, title: "Hardware & Commodities", parent: ict) }

  before do
    create(:support_category, title: "Books", parent: business_services)

    click_button "Agent Login"
    visit support_case_path(support_case, anchor: "case-details")
  end

  it "the current category is displayed within case details" do
    within ".govuk-summary-list__row", text: "Category" do
      expect(page).to have_content("Audit")
    end
  end

  describe "re-assigning case to another category" do
    before do
      within ".govuk-summary-list__row", text: "Category" do
        click_link "Change"
      end
    end

    it "lists all available categories with sub-categories nested under parents" do
      within ".govuk-fieldset", text: "Business Services" do
        expect(page).to have_field("Audit")
        expect(page).to have_field("Books")
      end

      within ".govuk-fieldset", text: "ICT" do
        expect(page).to have_field("Hardware & Commodities")
      end
    end

    it "updates the case category" do
      choose "Hardware & Commodities"
      click_button "Save and continue"

      expect(support_case.reload.category).to eq(ict_hardware)
    end

    context "when not selecting a category" do
      it "the category remains the same" do
        click_button "Save and continue"

        expect(support_case.reload.category).to eq(business_services_audit)
      end
    end
  end
end
