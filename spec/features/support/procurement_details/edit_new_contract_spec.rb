RSpec.feature "Editing new contract details in procurement tab section" do
  include_context "with an agent"

  let(:support_case) { create(:support_case, :opened, new_contract:) }

  before do
    visit support_case_path(support_case)
    click_link "Case details"
  end

  context "when adding values to new contract" do
    let(:new_contract) { create(:support_new_contract) }

    it "shows values as expected" do
      expect_blank_contract_details

      find("#pd-new-contract a").click
      fill_in_contract_details(
        day: "1",
        month: "1",
        year: "2000",
        duration: "6",
        spend: "500",
        supplier: "ACME",
        is_supplier_sme: true,
      )
      click_button I18n.t("support.case_contract.new.edit.submit")

      expect_populated_contract_details(
        start_date: "01 Jan 2000",
        duration: "6 months",
        spend: "£500.00",
        supplier: "ACME",
        is_supplier_sme: "Yes",
      )
    end

    it "calculates the end date" do
      find("#pd-new-contract a").click
      fill_in_contract_details(
        day: "1",
        month: "1",
        year: "2000",
        duration: "12",
      )
      click_button I18n.t("support.case_contract.new.edit.submit")

      contract = Support::NewContract.first
      expect(contract.ended_at).to eq Date.new(2001, 1, 1)
    end
  end

  context "when removing values from a new contract" do
    let(:new_contract) { create(:support_new_contract, :populated) }

    it "clears all fields when values are removed" do
      expect_populated_contract_details(
        start_date: "01 Jan 2020",
        duration: "1 year",
        spend: "£9.99",
        supplier: "ACME Corp",
        is_supplier_sme: "No",
      )

      find("#pd-new-contract a").click
      fill_in_contract_details(
        day: "",
        month: "",
        year: "",
        duration: "",
        spend: "",
        supplier: "",
        is_supplier_sme: false,
      )
      click_button I18n.t("support.case_contract.new.edit.submit")

      expect_blank_contract_details
    end
  end

  context "when submitting invalid data" do
    let(:new_contract) { create(:support_new_contract) }

    it "shows error for non-existent date" do
      find("#pd-new-contract a").click
      fill_in_contract_details(day: "31", month: "2", year: "2000")
      click_button I18n.t("support.case_contract.new.edit.submit")

      expect(page).to have_content "Start date of the contract is invalid"
      expect(page).to have_link "Start date of the contract is invalid", href: "#case-contracts-form-started-at-field-error"
    end

    it "shows error for non-numeric duration" do
      find("#pd-new-contract a").click
      fill_in_contract_details(duration: "abc")
      click_button I18n.t("support.case_contract.new.edit.submit")

      expect(page).to have_content "duration must be an integer"
    end

    it "shows error for negative spend" do
      find("#pd-new-contract a").click
      fill_in_contract_details(spend: "-100")
      click_button I18n.t("support.case_contract.new.edit.submit")

      expect(page).to have_content "Case contract details successfully changed"
      expect(page).to have_content "Contract spend -£100.00"
    end
  end

private

  def fill_in_contract_details(day: "", month: "", year: "", duration: "", spend: "", supplier: "", is_supplier_sme: false)
    fill_in "case_contracts_form[started_at(3i)]", with: day
    fill_in "case_contracts_form[started_at(2i)]", with: month
    fill_in "case_contracts_form[started_at(1i)]", with: year
    fill_in "case_contracts_form[duration]", with: duration
    fill_in "case_contracts_form[spend]", with: spend
    fill_in "case_contracts_form[supplier]", with: supplier
    check "case_contracts_form[is_supplier_sme]" if is_supplier_sme
  end

  def expect_blank_contract_details
    within "#pd-new-contract-details" do
      details = all(".govuk-summary-list__value")
      expect(details[0]).to have_text "-"
      expect(details[1]).to have_text "-"
      expect(details[2]).to have_text "-"
      expect(details[3]).to have_text "-"
      expect(details[4]).to have_text "No"
    end
  end

  def expect_populated_contract_details(start_date:, duration:, spend:, supplier:, is_supplier_sme:)
    within "#pd-new-contract-details" do
      details = all(".govuk-summary-list__value")
      expect(details[0]).to have_text start_date
      expect(details[1]).to have_text duration
      expect(details[2]).to have_text spend
      expect(details[3]).to have_text supplier
      expect(details[4]).to have_text is_supplier_sme
    end
  end
end
