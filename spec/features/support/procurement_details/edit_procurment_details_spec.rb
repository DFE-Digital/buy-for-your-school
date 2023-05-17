RSpec.feature "Edit case procurement details" do
  include_context "with an agent"

  let(:support_case) { create(:support_case, :opened, procurement: support_procurement) }
  let(:support_procurement) { create(:support_procurement, :blank) }

  before do
    visit edit_support_case_procurement_details_path(support_case)
  end

  it "shows heading" do
    expect(find("h1.govuk-heading-l")).to have_text "Update procurement details"
  end

  it "shows required agreement type options" do
    within(all("fieldset.govuk-fieldset")[0]) do
      expect(find("legend.govuk-fieldset__legend")).to have_text "Required agreement type"
      expect(page).to have_field "One-off"
      expect(page).to have_field "Ongoing"
    end
  end

  it "shows route to market options" do
    within(all("fieldset.govuk-fieldset")[1]) do
      expect(find("legend.govuk-fieldset__legend")).to have_text "Route to market"
      expect(page).to have_field "DfE Approved Deal / Framework"
      expect(page).to have_field "Bespoke Procurement"
      expect(page).to have_field "Direct Award"
    end
  end

  it "shows reason for route to market options" do
    within(all("fieldset.govuk-fieldset")[2]) do
      expect(find("legend.govuk-fieldset__legend")).to have_text "Reason for route to market"
      expect(page).to have_field "School Preference"
      expect(page).to have_field "DfE Deal / Framework Selected"
      expect(page).to have_field "No DfE Deal / Framework Available"
      expect(page).to have_field "Better Spec / Terms than DfE Deal"
    end
  end

  it "shows framework name dropdown", js: true do
    within(all("div.govuk-form-group")[3]) do
      expect(find("label.govuk-label")).to have_text "Framework name"
      expect(page).to have_field "case_procurement_details_form[framework_name]"
    end
  end

  it "shows the start date input" do
    within(all("fieldset.govuk-fieldset")[3]) do
      expect(find("legend.govuk-fieldset__legend")).to have_text "Start date of the procurement"
      expect(page).to have_field "Day"
      expect(page).to have_field "Month"
      expect(page).to have_field "Year"
    end
  end

  it "shows the end date input" do
    within(all("fieldset.govuk-fieldset")[4]) do
      expect(find("legend.govuk-fieldset__legend")).to have_text "End date of the procurement"
      expect(page).to have_field "Day"
      expect(page).to have_field "Month"
      expect(page).to have_field "Year"
    end
  end

  it "shows procurement stage options" do
    within(all("fieldset.govuk-fieldset")[5]) do
      expect(find("legend.govuk-fieldset__legend")).to have_text "Procurement stage"
      expect(page).to have_field "Need"
      expect(page).to have_field "Market Analysis"
      expect(page).to have_field "Sourcing Options"
      expect(page).to have_field "Go to Market"
      expect(page).to have_field "Evaluation"
      expect(page).to have_field "Contract Award"
      expect(page).to have_field "Handover"
    end
  end

  it "shows continue button" do
    expect(page).to have_button "Continue"
  end
end
