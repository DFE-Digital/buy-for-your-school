RSpec.feature "Case summary", :js do
  include_context "with a cec agent"

  before do
    visit "/cec/onboarding_cases/#{support_case.id}"
  end

  let(:dfe_energy_category) { create(:support_category, title: "DfE Energy for Schools service") }
  let(:energy_stage) { create(:support_procurement_stage, key: "onboarding_form", title: "Onboarding form", stage: "6") }
  let(:support_case) { create(:support_case, category: dfe_energy_category, agent: nil, procurement_stage: energy_stage) }

  describe "Back link" do
    it_behaves_like "breadcrumb_back_link" do
      let(:url) { "/cec/onboarding_cases" }
    end
  end

  it "shows the case reference heading" do
    expect(find("p#case-ref")).to have_text "000001"
  end

  it "has 7 visible tabs" do
    expect(all(".govuk-tabs__list-item", visible: true).count).to eq(7)
  end

  it "defaults to the onboarding summary tab" do
    expect(find(".govuk-tabs__list-item--selected")).to have_text "Onboarding summary"
  end

  it "does not have the tasklist tab" do
    expect(page).not_to have_css(".govuk-tabs__list-item", text: "Task list")
  end

  it "does not have the request tab" do
    expect(page).not_to have_css(".govuk-tabs__list-item", text: "Request")
  end

  it "does not have the link Move emails to existing case" do
    expect(page).not_to have_text "Move emails to existing case"
  end

  describe "School details tab" do
    before { visit "/cec/onboarding_cases/#{support_case.id}#school-details" }

    it "primary contact name" do
      within "#school-details" do
        expect(find(".govuk-summary-list")).to have_text "Contact name"
      end
    end
  end

  describe "Case details tab" do
    before { visit "/cec/onboarding_cases/#{support_case.id}#case-details" }

    it "lists request details" do
      within "#case-details" do
        expect(all(".govuk-summary-list__row")[0]).to have_text "Sub-category"
        expect(all(".govuk-summary-list__row")[1]).to have_text "Case level"
        expect(all(".govuk-summary-list__row")[2]).to have_text "Stage"
        expect(all(".govuk-summary-list__row")[3]).to have_text "Source"
        expect(all(".govuk-summary-list__row")[4]).to have_text "Next key date and description"
      end
    end
  end
end
