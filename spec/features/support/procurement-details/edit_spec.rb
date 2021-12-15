RSpec.feature "Edit case procurement details" do
  include_context "with an agent"

  let(:support_case) { create(:support_case, :opened, procurement: support_procurement) }
  let(:support_procurement) { create(:support_procurement, :blank) }

  before do
    click_button "Agent Login"
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

  it "shows framework name dropdown" do
    within(all("div.govuk-form-group")[3]) do
      expect(find("label.govuk-label")).to have_text "Framework name"
      expect(page).to have_select "case_procurement_details_form[framework_name]", options: ["-- Select framework --"], disabled: true
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

  it "shows procurement stage dropdown" do
    within(all("div.govuk-form-group")[12]) do
      expect(find("label.govuk-label")).to have_text "Procurement stage"
      expect(page).to have_select "case_procurement_details_form[stage]", options: ["-- Select stage --", "Need", "Market Analysis", "Sourcing Options", "Go to Market", "Evaluation", "Contract Award", "Handover"]
    end
  end

  it "shows continue button" do
    expect(page).to have_button "Continue"
  end

  context "when there are no errors" do
    before do
      # required agreement type
      choose "One-off"
      # route to market
      choose "Direct Award"
      # reason for route to market
      choose "School Preference"
      # start date
      fill_in "case_procurement_details_form[started_at(3i)]", with: "3"
      fill_in "case_procurement_details_form[started_at(2i)]", with: "12"
      fill_in "case_procurement_details_form[started_at(1i)]", with: "2020"
      # end date
      fill_in "case_procurement_details_form[ended_at(3i)]", with: "2"
      fill_in "case_procurement_details_form[ended_at(2i)]", with: "12"
      fill_in "case_procurement_details_form[ended_at(1i)]", with: "2021"
      # stage
      select "Need", from: "case_procurement_details_form[stage]"
      click_continue
    end

    it "redirects to case" do
      expect(page).to have_current_path "/support/cases/#{support_case.id}"
      expect(find("div.govuk-notification-banner__content")).to have_text "Successfully changed procurement details"
    end

    it "persists procurement details" do
      procurement = Support::Procurement.first
      expect(procurement.required_agreement_type).to eq "one_off"
      expect(procurement.route_to_market).to eq "direct_award"
      expect(procurement.reason_for_route_to_market).to eq "school_pref"
      expect(procurement.started_at).to eq Date.parse("2020-12-3")
      expect(procurement.ended_at).to eq Date.parse("2021-12-2")
      expect(procurement.stage).to eq "need"
    end
  end

  context "when dates fail validation" do
    before do
      # start date
      fill_in "case_procurement_details_form[started_at(3i)]", with: "3"
      fill_in "case_procurement_details_form[started_at(2i)]", with: "12"
      fill_in "case_procurement_details_form[started_at(1i)]", with: "2021"
      # end date
      fill_in "case_procurement_details_form[ended_at(3i)]", with: "2"
      fill_in "case_procurement_details_form[ended_at(2i)]", with: "12"
      fill_in "case_procurement_details_form[ended_at(1i)]", with: "2020"
      click_continue
    end

    it "shows error message above the field" do
      within(all("fieldset.govuk-fieldset")[3]) do
        expect(find("span#case-procurement-details-form-started-at-error")).to have_text "Start date of the procurement must come before the end date"
      end
    end

    it "shows error message in error summary" do
      within("div.govuk-error-summary") do
        expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
        expect(find("div.govuk-error-summary__body")).to have_link "Start date of the procurement must come before the end date", href: "#case-procurement-details-form-started-at-field-error"
      end
    end
  end
end
