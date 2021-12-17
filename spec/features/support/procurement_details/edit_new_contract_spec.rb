RSpec.feature "Editing new contract details in procurement tab section" do
  include_context "with an agent"

  let(:support_case) { create(:support_case, :opened, new_contract: new_contract) }

  before do
    click_button "Agent Login"
    visit support_case_path(support_case)
    click_link "Procurement details"
  end

  context "when adding values to new contract" do
    let(:new_contract) { create(:support_new_contract) }

    it "shows values as expected" do
      # check fields are blank
      within "[aria-labelledby='pd-new-contract']" do
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
      within "[aria-labelledby='pd-new-contract']" do
        details = all(".govuk-summary-list__value")
        expect(details[0]).to have_text "1 January 2000"
        expect(details[1]).to have_text "6 months"
        expect(details[2]).to have_text "£500.00"
        expect(details[3]).to have_text "ACME"
      end
    end
  end

  context "when removing values from a new contract" do
    let(:new_contract) { create(:support_new_contract, :populated) }

    it "when removing values from an existing contract" do
      # check fields are blank
      within "[aria-labelledby='pd-new-contract']" do
        details = all(".govuk-summary-list__value")
        expect(details[0]).to have_text "1 January 2020"
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
      within "[aria-labelledby='pd-new-contract']" do
        details = all(".govuk-summary-list__value")
        expect(details[0]).to have_text "-"
        expect(details[1]).to have_text "-"
        expect(details[2]).to have_text "-"
        expect(details[3]).to have_text "-"
      end
    end
  end
end
