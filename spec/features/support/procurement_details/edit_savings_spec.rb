RSpec.feature "Editing procurement savings details" do
  include_context "with an agent"

  let(:support_case) { create(:support_case, :opened) }

  before do
    visit support_case_path(support_case)
    click_link "Case details"
  end

  context "when adding values to savings" do
    it "shows values as expected" do
      # check fields are blank
      within "#pd-savings-details" do
        expect(page).not_to have_text "Realised"
        expect(page).not_to have_text "[Previous spend] - [Cheapest quote]"
        expect(page).not_to have_text "[Previous spend] - [Award Price]"
      end
      # navigate to edit page for savings details
      find("#pd-savings a").click
      # input choices
      find("#case-savings-form-savings-status-realised-field").click
      find("#case-savings-form-savings-estimate-method-previous-minus-cheapest-field").click
      find("#case-savings-form-savings-actual-method-previous-minus-award-field").click
      # input savings values
      fill_in "case-savings-form-savings-estimate-field", with: 1000
      fill_in "case-savings-form-savings-actual-field", with: 500
      # save
      click_on "Continue"
      # check fields are populated
      within "#pd-savings-details" do
        expect(page).to have_text "Realised"
        expect(page).to have_text "[Previous spend] - [Cheapest quote]"
        expect(page).to have_text "[Previous spend] - [Award Price]"
        expect(page).to have_text "£1,000.00"
        expect(page).to have_text "£500.00"
      end
    end

    it "shows error message when validation fails" do
      find("#pd-savings a").click
      fill_in "case-savings-form-savings-estimate-field", with: "a"
      click_on "Continue"
      expect(find("div.govuk-error-summary")).to have_link "savings_estimate must be a decimal", href: "#case-savings-form-savings-estimate-field-error"
    end
  end
end
