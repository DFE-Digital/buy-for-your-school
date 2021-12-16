RSpec.feature "Editing new contract details in procurement tab section" do
  include_context "with an agent"

  let(:support_case) { create(:support_case, :opened, new_contract: new_contract) }
  let(:new_contract) { create(:support_new_contract) }

  before do
    click_button "Agent Login"
    visit support_case_path(support_case)
    click_link "Procurement details"
  end

  context "when amending existing contract details" do
    it "shows values where expected" do
      # check fields are blank
      within "[aria-labelledby='pd-new-contract']" do
        expect(page).not_to have_text "Start date of new contract"
        expect(page).not_to have_text "Duration of new contract in months"
        expect(page).not_to have_text "New contract spend"
        expect(page).not_to have_text "New contract supplier"
      end
    end

    it "shows the expected fields on the edit page" do
      find("#pd-new-contract a").click
      within(all("div.govuk-form-group")[5]) do
        expect(find(".govuk-label")).to have_text "New contract spend"
      end

      within(all("div.govuk-form-group")[6]) do
        expect(find(".govuk-label")).to have_text "New contract supplier"
      end

      # input contract details
      fill_in "case_contracts_form[started_at(3i)]", with: "2"
      fill_in "case_contracts_form[started_at(2i)]", with: "11"
      fill_in "case_contracts_form[started_at(1i)]", with: "2002"

      fill_in "case-contracts-form-spend-field", with: "300"
      fill_in "case-contracts-form-supplier-field", with: "test contract"
      # save
      click_on "Continue"
    end

    it "persists existing contract details" do
      find("#pd-new-contract a").click
      # input contract details
      fill_in "case_contracts_form[started_at(3i)]", with: "2"
      fill_in "case_contracts_form[started_at(2i)]", with: "11"
      fill_in "case_contracts_form[started_at(1i)]", with: "2002"

      fill_in "case-contracts-form-spend-field", with: "300"
      fill_in "case-contracts-form-supplier-field", with: "test contract"
      # save
      click_on "Continue"

      new_contract_data = Support::Contract.first
      expect(new_contract_data.spend).to eq 300
      expect(new_contract_data.supplier).to eq "test contract"
      expect(new_contract_data.started_at).to eq Date.parse("2002-11-2")
    end
  end
end
