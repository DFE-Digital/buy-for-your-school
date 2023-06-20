RSpec.feature "Editing existing contract details in procurement tab section" do
  include_context "with an agent"

  let(:support_case) { create(:support_case, :opened, existing_contract:) }

  before do
    visit support_case_path(support_case)
    click_link "Case details"
  end

  context "when adding values to existing contract" do
    let(:existing_contract) { create(:support_existing_contract) }

    it "shows values as expected" do
      # check fields are blank
      within "#pd-existing-contract-details" do
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
      within "#pd-existing-contract-details" do
        details = all(".govuk-summary-list__value")
        expect(details[0]).to have_text "1 Jan 2000"
        expect(details[1]).to have_text "6 months"
        expect(details[2]).to have_text "£500.00"
        expect(details[3]).to have_text "ACME"
      end
    end

    it "calculates the start date" do
      # navigate to edit page for existing contract
      find("#pd-existing-contract a").click
      # input end date
      fill_in "case_contracts_form[ended_at(3i)]", with: "1"
      fill_in "case_contracts_form[ended_at(2i)]", with: "1"
      fill_in "case_contracts_form[ended_at(1i)]", with: "2000"
      # input contract length (months)
      fill_in "case-contracts-form-duration-field", with: 12
      # save
      click_continue

      contract = Support::ExistingContract.first
      expect(contract.started_at).to eq Date.parse("1999-01-01")
    end
  end

  context "when removing values from an existing contract" do
    let(:existing_contract) { create(:support_existing_contract, :populated) }

    it "replaces values with a hyphen to show they are blank" do
      # check fields are blank
      within "#pd-existing-contract-details" do
        details = all(".govuk-summary-list__value")
        expect(details[0]).to have_text "1 Jan 2021"
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
      within "#pd-existing-contract-details" do
        details = all(".govuk-summary-list__value")
        expect(details[0]).to have_text "-"
        expect(details[1]).to have_text "-"
        expect(details[2]).to have_text "-"
        expect(details[3]).to have_text "-"
      end
    end
  end

  context "when dates fail validation due to non-existent dates" do
    let(:existing_contract) { create(:support_existing_contract) }

    before do
      find("#pd-existing-contract a").click
      # input end date
      fill_in "case_contracts_form[ended_at(3i)]", with: "31"
      fill_in "case_contracts_form[ended_at(2i)]", with: "2"
      fill_in "case_contracts_form[ended_at(1i)]", with: "2020"
      click_continue
    end

    it "shows error message above the field" do
      within(all("fieldset.govuk-fieldset")[0]) do
        expect(find("p#case-contracts-form-ended-at-error")).to have_text "End date of the contract is invalid"
      end
    end

    it "shows error message in error summary" do
      within("div.govuk-error-summary") do
        expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
        expect(find("div.govuk-error-summary__body")).to have_link "End date of the contract is invalid", href: "#case-contracts-form-ended-at-field-error"
      end
    end
  end
end
