RSpec.feature "Editing new contract details in procurement tab section" do
  include_context "with an agent"

  let(:support_case) { create(:support_case, :opened, new_contract:) }

  before do
    click_button "Agent Login"
    visit support_case_path(support_case)
    click_link "Case details"
  end

  context "when adding values to new contract" do
    let(:new_contract) { create(:support_new_contract) }

    it "shows values as expected" do
      # check fields are blank
      within "#pd-new-contract-details" do
        details = all(".govuk-summary-list__value")
        expect(details[0]).to have_text "-"
        expect(details[1]).to have_text "-"
        expect(details[2]).to have_text "-"
        expect(details[3]).to have_text "-"
      end
      # navigate to edit page for savings details
      find("#pd-new-contract a").click
      # input start date
      fill_in "case_contracts_form[started_at(3i)]", with: "1"
      fill_in "case_contracts_form[started_at(2i)]", with: "1"
      fill_in "case_contracts_form[started_at(1i)]", with: "2000"
      # input contract length (months)
      fill_in "case-contracts-form-duration-field", with: 6
      fill_in "case-contracts-form-spend-field", with: 500
      fill_in "case-contracts-form-supplier-field", with: "ACME"
      # save
      click_on "Continue"
      # check fields are populated
      within "#pd-new-contract-details" do
        details = all(".govuk-summary-list__value")
        expect(details[0]).to have_text "1 Jan 2000"
        expect(details[1]).to have_text "6 months"
        expect(details[2]).to have_text "£500.00"
        expect(details[3]).to have_text "ACME"
      end
    end

    it "calculates the end date" do
      # navigate to edit page for new contract
      find("#pd-new-contract a").click
      # input start date
      fill_in "case_contracts_form[started_at(3i)]", with: "1"
      fill_in "case_contracts_form[started_at(2i)]", with: "1"
      fill_in "case_contracts_form[started_at(1i)]", with: "2000"
      # input contract length (months)
      fill_in "case-contracts-form-duration-field", with: 12
      # save
      click_continue

      contract = Support::NewContract.first
      expect(contract.ended_at).to eq Date.parse("2001-01-01")
    end
  end

  context "when removing values from a new contract" do
    let(:new_contract) { create(:support_new_contract, :populated) }

    it "when removing values from an existing contract" do
      # check fields are blank
      within "#pd-new-contract-details" do
        details = all(".govuk-summary-list__value")
        expect(details[0]).to have_text "1 Jan 2020"
        expect(details[1]).to have_text "1 year"
        expect(details[2]).to have_text "£9.99"
        expect(details[3]).to have_text "ACME Corp"
      end
      # navigate to edit page for savings details
      find("#pd-new-contract a").click
      # input start date
      fill_in "case_contracts_form[started_at(3i)]", with: ""
      fill_in "case_contracts_form[started_at(2i)]", with: ""
      fill_in "case_contracts_form[started_at(1i)]", with: ""
      # input contract length (months)
      fill_in "case-contracts-form-duration-field", with: ""
      fill_in "case-contracts-form-spend-field", with: ""
      fill_in "case-contracts-form-supplier-field", with: ""
      # save
      click_on "Continue"
      # check fields are populated
      within "#pd-new-contract-details" do
        details = all(".govuk-summary-list__value")
        expect(details[0]).to have_text "-"
        expect(details[1]).to have_text "-"
        expect(details[2]).to have_text "-"
        expect(details[3]).to have_text "-"
      end
    end
  end

  context "when dates fail validation due to non-existent dates" do
    let(:new_contract) { create(:support_new_contract) }

    before do
      find("#pd-new-contract a").click
      # input start date
      fill_in "case_contracts_form[started_at(3i)]", with: "31"
      fill_in "case_contracts_form[started_at(2i)]", with: "2"
      fill_in "case_contracts_form[started_at(1i)]", with: "2000"
      click_continue
    end

    it "shows error message above the field" do
      within(all("fieldset.govuk-fieldset")[0]) do
        expect(find("p#case-contracts-form-started-at-error")).to have_text "Start date of the contract is invalid"
      end
    end

    it "shows error message in error summary" do
      within("div.govuk-error-summary") do
        expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
        expect(find("div.govuk-error-summary__body")).to have_link "Start date of the contract is invalid", href: "#case-contracts-form-started-at-field-error"
      end
    end
  end
end
