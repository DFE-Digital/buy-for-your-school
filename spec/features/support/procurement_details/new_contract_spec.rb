FactoryBot.define do
  factory :support_new_contract, class: "Support::NewContract" do
    type { "Support::NewContract" }
    supplier { "test" }
    started_at { "2020-10-01" }
    spend { "300" }
  end
end

RSpec.feature "Editing new contract details in procurement tab section" do
  include_context "with an agent"

  let(:support_case) { create(:support_case, :opened, new_contract: new_contract) }
  let(:new_contract) { create(:support_new_contract) }

  before do
    click_button "Agent Login"
    visit support_case_path(support_case)
    click_link "Procurement details"
  end

  context "when amending new contract details" do
    it "shows values where expected" do
      # check fields are blank
      within "[aria-labelledby='pd-existing-contract']" do
        expect(page).not_to have_text("Start date of existing contract (optional)")
        expect(page).not_to have_text("Duration of existing contract in months (optional)")
        expect(page).not_to have_text("Existing contract spend (optional)")
        expect(page).not_to have_text("Existing contract supplier (optional)")
      end
    end

    it "shows the expected fields on the edit page" do
      pp page.source
      find("#pd-new-contract-change a").click
      within(all("div.govuk-form-group")[5]) do
        expect(find(".govuk-label")).to have_text "New contract spend (optional)"
      end

      within(all("div.govuk-form-group")[6]) do
        expect(find(".govuk-label")).to have_text "New contract supplier (optional)"
      end

      # input contract details
      fill_in "case-contracts-form-spend-field", with: "300"
      fill_in "case-contracts-form-supplier-field", with: "test name"
      # save
      click_on "Continue"
    end

    it "persists existing contract details" do
      new_contract_data = Support::Contract.first
      expect(new_contract_data.spend).to eq 300
      expect(new_contract_data.supplier).to eq "test name"
    end
  end
end
