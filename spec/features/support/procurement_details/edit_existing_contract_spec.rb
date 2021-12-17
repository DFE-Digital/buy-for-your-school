RSpec.feature "Editing existing contract details in procurement tab section" do
  include_context "with an agent"

  let(:support_case) { create(:support_case, :opened, existing_contract: existing_contract) }

  before do
    click_button "Agent Login"
    visit support_case_path(support_case)
    click_link "Procurement details"
  end

  context "when adding values to existing contract" do
    let(:existing_contract) { create(:support_existing_contract) }

    it "shows values as expected" do
      # check fields are blank
      within "[aria-labelledby='pd-existing-contract']" do
        details = all(".govuk-summary-list__value")
        expect(details[0]).to have_text "-"
        expect(details[1]).to have_text "-"
        expect(details[2]).to have_text "-"
        expect(details[3]).to have_text "-"
      end
      # navigate to edit page for savings details
      find("#pd-existing-contract a").click
      # input end date
      fill_in "case_contracts_form[ended_at(3i)]", with: "1"
      fill_in "case_contracts_form[ended_at(2i)]", with: "1"
      fill_in "case_contracts_form[ended_at(1i)]", with: "2000"
      # input contract length (months)
      fill_in "case-contracts-form-duration-field", with: 6
      fill_in "case-contracts-form-spend-field", with: 500
      fill_in "case-contracts-form-supplier-field", with: "ACME"
      # save
      click_on "Continue"
      # check fields are populated
      within "[aria-labelledby='pd-existing-contract']" do
        details = all(".govuk-summary-list__value")
        expect(details[0]).to have_text "1 January 2000"
        expect(details[1]).to have_text "6 months"
        expect(details[2]).to have_text "£500.00"
        expect(details[3]).to have_text "ACME"
      end
    end
  end

  context "when removing values from an existing contract" do
    let(:existing_contract) { create(:support_existing_contract, :populated) }

    it "replaces values with a hyphen to show they are blank" do
      # check fields are blank
      within "[aria-labelledby='pd-existing-contract']" do
        details = all(".govuk-summary-list__value")
        expect(details[0]).to have_text "1 January 2021"
        expect(details[1]).to have_text "1 year"
        expect(details[2]).to have_text "£9.99"
        expect(details[3]).to have_text "ACME Corp"
      end
      # navigate to edit page for savings details
      find("#pd-existing-contract a").click
      # input end date
      fill_in "case_contracts_form[ended_at(3i)]", with: ""
      fill_in "case_contracts_form[ended_at(2i)]", with: ""
      fill_in "case_contracts_form[ended_at(1i)]", with: ""
      # input contract length (months)
      fill_in "case-contracts-form-duration-field", with: ""
      fill_in "case-contracts-form-spend-field", with: ""
      fill_in "case-contracts-form-supplier-field", with: ""
      # save
      click_on "Continue"
      # check fields are populated
      within "[aria-labelledby='pd-existing-contract']" do
        details = all(".govuk-summary-list__value")
        expect(details[0]).to have_text "-"
        expect(details[1]).to have_text "-"
        expect(details[2]).to have_text "-"
        expect(details[3]).to have_text "-"
      end
    end
  end
end
