RSpec.feature "Supported Cases View" do
  before { user_is_signed_in }

  context "when on the index page" do
    before { visit "/support/cases" }

    it "has 3 visibile tabs" do
      expect(all(".govuk-tabs__list-item", visible: true).count).to eq(3)
    end

    it "defaults to the 'My Cases' tab" do
      expect(find(".govuk-tabs__list-item--selected")).to have_text "My cases"
    end

    it "shows cases" do
      expect(find("#my-cases .govuk-table")).to be_visible

      # TODO: Change ".all.count" with ".count"
      expect(all("#my-cases .govuk-table__row").count).to eq(Support::Case.all.count + 1)
    end

    it "shows correct columns" do
      expect(find("#my-cases .govuk-table__head")).to have_text "Organisation Category Status Last updated"
    end
  end

  context "when on the show page" do
    before { visit "/support/cases/1" }

    it "has 3 visible tabs" do
      expect(all(".govuk-tabs__list-item", visible: true).count).to eq(3)
    end

    it "defaults to the 'School details' tab" do
      expect(find(".govuk-tabs__list-item--selected")).to have_text "School details"
    end

    it "shows School details section" do
      expect(find("#school-details .govuk-summary-list")).to be_visible
    end

    it "School details section contain contact name" do
      expect(find("#school-details .govuk-summary-list")).to have_text "Contact name"
    end
  end
end
