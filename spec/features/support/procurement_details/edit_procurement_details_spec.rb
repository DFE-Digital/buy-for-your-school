RSpec.feature "Edit case procurement details" do
  include_context "with an agent"

  let(:support_case) { create(:support_case, :opened, procurement: support_procurement) }
  let(:support_procurement) { create(:support_procurement, :blank) }
  let(:framework) { create(:frameworks_framework, reference: "F123", short_name: "Example Framework") }

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

  it "shows framework name dropdown", :js do
    within(all("div.govuk-form-group")[3]) do
      expect(find("label.govuk-label")).to have_text "Framework name"
      expect(page).to have_field "case_procurement_details_form[framework_name]"
    end
  end

  context "when the framework dropdown does not contain a value", :js do
    it "does not have a clear framework link" do
      within(all("div.govuk-form-group")[3]) do
        expect(page).to have_css(".govuk-\\!-display-none")
      end
    end
  end

  context "when the framework dropdown contains a value", :js do
    let(:support_procurement) { create(:support_procurement, stage: :market_analysis, register_framework: framework) }

    it "has a clear framework link, which removes the framework and link when clicked" do
      within(all("div.govuk-form-group")[3]) do
        expect(page).not_to have_css(".govuk-\\!-display-none", text: "Clear selected framework")
      end

      find("a.govuk-link", text: "Clear selected framework").click

      within(all("div.govuk-form-group")[3]) do
        expect(find("#framework-autocomplete")).to have_text ""
        expect(page).to have_css(".govuk-\\!-display-none", text: "Clear selected framework")
      end
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

  it "shows the e-portal reference" do
    expect(page).to have_css("label.govuk-label", text: I18n.t("support.procurement_details.edit.e_portal_reference.header"))
  end

  it "shows continue button" do
    expect(page).to have_button "Continue"
  end
end
