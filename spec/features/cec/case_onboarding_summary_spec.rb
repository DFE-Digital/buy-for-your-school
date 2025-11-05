describe "Case onboarding summary", :js do
  include_context "with a cec agent"

  let(:support_organisation) { create(:support_organisation) }
  let(:support_case) { create(:support_case, organisation: support_organisation) }
  let(:onboarding_case) { create(:onboarding_case, support_case:) }
  let(:case_organisation) { create(:energy_onboarding_case_organisation, :with_energy_details, onboarding_case:, onboardable: support_organisation) }
  let(:gas_single_multi) { "single" }
  let(:gas_meter_numbers) { %w[654321] }
  let(:electricity_meter_type) { "single" }
  let(:electricity_meter_numbers) { %w[1234567890123] }

  before do
    case_organisation.update!(gas_single_multi:, electricity_meter_type:)

    gas_meter_numbers.each do |mprn|
      create(:energy_gas_meter, :with_valid_data, mprn:, onboarding_case_organisation: case_organisation)
    end

    electricity_meter_numbers.each do |mpan|
      create(:energy_electricity_meter, :with_valid_data, mpan:, energy_onboarding_case_organisation_id: case_organisation.id)
    end

    visit "/cec/onboarding_cases/#{support_case.id}#onboarding-summary"
  end

  context "when the case is complete" do
    it "has the correct sections and no change links" do
      within "#onboarding-summary" do
        expect(page).to have_text "Current contract details"
        expect(page).to have_text "Current gas supplier"
        expect(page).to have_text "British Gas"

        expect(page).to have_text "Gas meters and usage"
        expect(page).to have_text "Is this a single meter or multi meter site?"
        expect(page).to have_text "Single meter"

        expect(page).to have_text "Electricity meters and usage"

        expect(page).to have_text "Site contact details"
        expect(page).to have_text "ned@kelly.com"

        expect(page).to have_text "VAT Declaration"
        expect(page).to have_text "VAT rate"

        expect(page).to have_text "Billing preferences"
        expect(page).to have_text "How would you like to receive your bills?"

        expect(page).not_to have_link "Change"
      end
    end
  end
end
