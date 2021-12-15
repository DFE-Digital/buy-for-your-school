RSpec.feature "Editing existing contract details in procurement tab section" do
  include_context "with an agent"

  let(:support_case) { create(:support_case, :opened, existing_contract: existing_contract) }
  let(:existing_contract) { create(:support_existing_contract) }

  before do
    click_button "Agent Login"
    visit support_case_path(support_case)
    click_link "Procurement details"
  end

  context "when amending existing contract details" do
    it "shows values where expected" do
      # check fields are blank
      within "[aria-labelledby='pd-existing-contract']" do
        expect(page).not_to have_text("End date of existing contract")
        expect(page).not_to have_text("Duration of existing contract in months")
        expect(page).not_to have_text("Existing contract spend")
        expect(page).not_to have_text("Existing contract supplier")
      end
    end

    it "shows the expected fields on the edit page" do
      find("#pd-existing-contract a").click
      within(all("div.govuk-form-group")[5]) do
        expect(find(".govuk-label")).to have_text "Existing contract spend"
      end

      within(all("div.govuk-form-group")[6]) do
        expect(find(".govuk-label")).to have_text "Existing contract supplier"
      end

      # input contract details
      fill_in "case_contracts_form[ended_at(3i)]", with: "5"
      fill_in "case_contracts_form[ended_at(2i)]", with: "7"
      fill_in "case_contracts_form[ended_at(1i)]", with: "2014"

      fill_in "case-contracts-form-spend-field", with: "500"
      fill_in "case-contracts-form-supplier-field", with: "test"
      # save
      click_on "Continue"
    end

    it "persists existing contract details" do
      find("#pd-existing-contract a").click
      # input contract details
      fill_in "case_contracts_form[ended_at(3i)]", with: "5"
      fill_in "case_contracts_form[ended_at(2i)]", with: "7"
      fill_in "case_contracts_form[ended_at(1i)]", with: "2014"

      fill_in "case-contracts-form-spend-field", with: "500"
      fill_in "case-contracts-form-supplier-field", with: "test"
      # save
      click_on "Continue"

      existing_contract_data = Support::Contract.first
      expect(existing_contract_data.ended_at).to eq Date.parse("2014-7-5")
      expect(existing_contract_data.spend).to eq 500
      expect(existing_contract_data.supplier).to eq "test"
    end
  end
end
