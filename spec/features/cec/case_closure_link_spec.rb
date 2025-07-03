RSpec.feature "Case closure", :js do
  include_context "with a cec agent"

  let(:dfe_energy_category) { create(:support_category, title: "DfE Energy for Schools service") }
  let(:energy_stage) { create(:support_procurement_stage, key: "onboarding_form", title: "Onboarding form", stage: "6") }
  let(:support_case) { create(:support_case, category: dfe_energy_category, state: :opened, agent: nil, procurement_stage: energy_stage) }
  let(:link) { "/cec/onboarding_cases/#{support_case.id}" }

  describe "Check Reject case link" do
    it "page should not have Reject case link" do
      visit link
      expect(page).not_to have_link("Reject case")
    end

    it "page should have Reject case link" do
      agent.update!(roles: %w[cec cec_admin])
      visit link
      expect(page).to have_link("Reject case")
    end
  end
end
